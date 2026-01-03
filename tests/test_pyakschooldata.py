"""
Tests for pyakschooldata Python wrapper.

Minimal smoke tests - the actual data logic is tested by R testthat.
These just verify the Python wrapper imports and exposes expected functions.
"""

import pytest


def test_import_package():
    """Package imports successfully."""
    import pyakschooldata
    assert pyakschooldata is not None


def test_has_fetch_enr():
    """fetch_enr function is available."""
    import pyakschooldata
    assert hasattr(pyakschooldata, 'fetch_enr')
    assert callable(pyakschooldata.fetch_enr)


def test_has_get_available_years():
    """get_available_years function is available."""
    import pyakschooldata
    assert hasattr(pyakschooldata, 'get_available_years')
    assert callable(pyakschooldata.get_available_years)


def test_has_version():
    """Package has a version string."""
    import pyakschooldata
    assert hasattr(pyakschooldata, '__version__')
    assert isinstance(pyakschooldata.__version__, str)
