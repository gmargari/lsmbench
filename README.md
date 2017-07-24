Dependencies
============

```bash
# For bench.c
sudo apt-get install libsnappy-dev

# For HyperLevelDB
sudo apt-get install autoconf libtool

# For RocksDB
sudo apt-get install libgflags-dev
```

Compile
=======

```bash
# Clone all repos, compile their libraries, build benchmark with each library.
# Edit Makefile and uncomment line "MAKE_JOBS =" to enable parallel make.
make

```
