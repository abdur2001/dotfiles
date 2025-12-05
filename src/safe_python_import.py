import importlib
from typing import Optional


def safe_import(name: str, final_name: Optional[str] = None) -> dict:
    globals_update_dict = {}
    try:
        module = importlib.import_module(name)
        if final_name is None:
            final_name = name
        globals_update_dict[final_name] = module
    except ImportError:
        print(f"Could not import '{name}'")
    return globals_update_dict
