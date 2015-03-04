mkdir -p ensurepip/_bundled
cd ensurepip
wget https://github.com/akheron/cpython/raw/v3.4.0/Lib/ensurepip/__init__.py
wget https://github.com/akheron/cpython/raw/v3.4.0/Lib/ensurepip/__main__.py
wget https://github.com/akheron/cpython/raw/v3.4.0/Lib/ensurepip/_uninstall.py
cd _bundled
wget https://github.com/akheron/cpython/raw/v3.4.0/Lib/ensurepip/_bundled/pip-1.5.4-py2.py3-none-any.whl
wget https://github.com/akheron/cpython/raw/v3.4.0/Lib/ensurepip/_bundled/setuptools-2.1-py2.py3-none-any.whl
