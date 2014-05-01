# .files

1. check out the repo
2. update submodules<sup>2</sup>
3. symlink dot files
4. install system dependencies<sup>4</sup>

----

### <sup>2</sup>updating submodules

```sh
git submodule init
git submodule update --recursive
```

### <sup>4</sup>installing dependencies

```sh
sudo emerge --ask --tree \
	dev-python/flake8 \
	dev-python/jedi \
	dev-ruby/sass \
	net-libs/nodejs
```

Flake8 will pull in PEP8 and PyFlakes. Node.js is required by less.js.
