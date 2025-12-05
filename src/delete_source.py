#!/opt/third/uv/bin/uv run
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "authsvc",
#     "requests",
#     "click",
#     "spdseclients",
# ]
# ///

import getpass
import logging

import click
from sptseriesclient import TimeseriesClient

logger = logging.getLogger(__name__)

USER = getpass.getuser()


@click.command()
@click.option(
    "--source-name",
    required=True,
    help="The name of the tss source to delete",
)
@click.option(
    "--source-only",
    is_flag=True,
    help="Delete only the source, no table deletions",
)
def delete_source(source_name: str, source_only: bool) -> None:
    if "dev" not in source_name:
        logger.warning(
            "A possible production source_name was given as input. Aborting."
        )
        quit(0)

    ts_client = TimeseriesClient.create(f"{USER}_ts_tools")

    if not source_only:
        if not click.confirm(
            f"Are you sure you want to DELETE all tables in source: {source_name}"
        ):
            quit(0)

        table_names = get_preexisting_tables(ts_client, source_name)
        for table_name in table_names:
            print(f"Deleting all data in {source_name}.{table_name}")
            ts_client.delete(source_name, table_name)
            print(f"Deleting table {table_name} in source {source_name}")
            ts_client.delete_table(source_name, table_name)

    print(f"Deleting source {source_name}")
    ts_client.delete_source(source_name)


def get_preexisting_tables(
    ts_client: TimeseriesClient,
    source_name: str,
) -> list[str]:
    return list(ts_client.get_tables(source_name).tables)


if __name__ == "__main__":
    delete_source()
