import os
import subprocess
import io
from pydantic import BaseModel, field_validator
import yaml
import click
import sys
from pathlib import Path
from beartype import beartype


class SymlinkError(click.ClickException): ...


def query(question: str, default: str | None = "yes") -> bool:
    """
    Ask a yes/no question via raw_input() and return the given answer.

    Parameters
    ----------
    question : str
        The question to ask.
    default : str, optional
        The default answer if the user just hits <Enter>. The default is 'yes'.
        If None, an answer is required of the user.

    Returns
    -------
    bool

    """
    if default is None:
        prompt = " [y/n] "
    elif default == "yes":
        prompt = " [Y/n] "
    elif default == "no":
        prompt = " [y/N] "
    else:
        raise ValueError("invalid default answer: '%s'" % default)

    valid = {"yes": True, "y": True, "ye": True, "no": False, "n": False}

    while True:
        sys.stdout.write(question + prompt)
        choice = input().lower()
        if default is not None and choice == "":
            return valid[default]
        elif choice in valid:
            return valid[choice]
        else:
            sys.stdout.write("Please respond with 'yes' or 'no' " "(or 'y' or 'n').\n")


def make_symlink(
    *,
    source: Path,
    target: Path,
) -> bool:
    """
    Create a symlink to a file or directory.

    Parameters
    ----------
    source : Path
        The path of the file or directory to symlink.
    target : Path
        The symlink target.

    Returns
    -------
    bool
        True on success, False on failure.

    """
    source = source.resolve()
    target = target.absolute()

    if not source.exists():
        raise SymlinkError(f"{source} does not exist!")

    target_dir = target.parent

    if not target_dir.is_dir():
        if not query(f"Create directory: {target_dir}?"):
            click.echo(f"Directory {target_dir} not created!")
            return False

        os.makedirs(target_dir)

    if not target.exists():
        cmd = ("ln", "-s", str(source), str(target))
        if query(f"Run: {' '.join(cmd)}?"):
            return subprocess.run(cmd).returncode == 0
        return False

    fmt_path = f"{str(target):<50s}"

    if target.is_symlink():
        if not target.exists():
            raise SymlinkError(f"{fmt_path} is a broken link!")

        if target.resolve() == source:
            click.echo(
                f"{fmt_path} is already symlinked to the desired file    {source}"
            )
            return True

        raise SymlinkError(
            f"{fmt_path} is already symlinked to the unexpected file {target.resolve()}"
        )
    else:
        click.echo(f"{fmt_path} already exists and is not symlinked!")
        return False

    raise SymlinkError("Internal error")


class LinkConfig(BaseModel):
    src: str
    tgt: str
    chmod: str | None = None

    @field_validator("chmod", mode="before")
    def validate_chmod(cls, v: str | int | None) -> str | None:
        if v is None:
            return None
        if isinstance(v, int):
            return str(v)
        return v


class Configuration(BaseModel):
    home: list[str]
    home_bin: list[str]
    links: list[LinkConfig]


@click.command()
@click.option(
    "--src-dir",
    type=click.Path(
        exists=True, file_okay=False, dir_okay=True, resolve_path=True, path_type=Path
    ),
    required=True,
)
@click.option(
    "--config",
    type=click.File("r"),
    required=True,
)
@beartype
def cli(src_dir: Path, config: io.TextIOWrapper) -> None:
    click.echo("Creating Symlinks")

    src_dir = src_dir.resolve()
    click.echo(f"src directory: {src_dir}")

    configuration = Configuration.model_validate(yaml.safe_load(config))

    error = False
    for name in configuration.home:
        error |= not make_symlink(
            source=src_dir / name, target=Path("~").expanduser() / name
        )

    for name in configuration.home_bin:
        error |= not make_symlink(
            source=src_dir / name, target=Path("~").expanduser() / "bin" / name
        )

    for spec in configuration.links:
        src_path = (src_dir / Path(spec.src)).resolve()
        target = Path(spec.tgt).expanduser().absolute()

        if spec.chmod is not None:
            chmod_cmd = ("chmod", spec.chmod, str(src_path))
            if subprocess.run(chmod_cmd).returncode != 0:
                raise Exception("Could not execute: {}".format(" ".join(chmod_cmd)))

        error |= not make_symlink(source=src_path, target=target)

    if error:
        raise SymlinkError("One or more errors encountered!")
