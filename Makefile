clean:
	rm -rf build/ dist/ pycld3.cpp src/cld_3/ pycld3.egg-info

publish:
	./publish.sh

test:
	python -m pip install --quiet -e . && python -m unittest test_pycld3.py
