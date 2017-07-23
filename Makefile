BINARIES = leveldb_bench rangedb_bench flodb_bench hyperleveldb_bench rocksdb_bench
CPP_FLAGS = -Wall -Wno-sign-compare -std=c++11
LIBRARIES = -lpthread -pthread -lsnappy
MAKE_JOBS = -j 8 # Use multiple parallel jobs

.PHONY = all clean init

.DEFAULT_GOAL := all

init:
	git submodule update --init

all: init $(BINARIES)

clean:
	rm -f $(BINARIES)

leveldb/out-static/libleveldb.a:
	cd leveldb; make $(MAKE_JOBS)

rangedb/libleveldb.a:
	cd rangedb; make $(MAKE_JOBS)

flodb/libleveldb.a:
	cd flodb; make $(MAKE_JOBS) MHT=1 MSL=96 ASCY_MEMTABLE=3 N_DRAINING_THREADS=1

hyperleveldb/.libs/libhyperleveldb.a:
	cd hyperleveldb; [ -f Makefile ] || (autoreconf -i; ./configure; sed -i '/^EXTRA_CFLAGS =/ s/$$/ -lsnappy/' Makefile); make $(MAKE_JOBS)

rocksdb/librocksdb.a:
	cd rocksdb; make $(MAKE_JOBS) static_lib

leveldb_bench: bench/bench.c leveldb/out-static/libleveldb.a
	g++ $(CPP_FLAGS) -o $@ $< -Ileveldb/include/ leveldb/out-static/libleveldb.a $(LIBRARIES) -DLEVELDB_COMPILE

rangedb_bench: bench/bench.c rangedb/libleveldb.a
	g++ $(CPP_FLAGS) -o $@ $< -Irangedb/include/ rangedb/libleveldb.a $(LIBRARIES) -DRANGEDB_COMPILE

flodb_bench: bench/bench.c flodb/libleveldb.a
	g++ $(CPP_FLAGS) -o $@ $< -Iflodb/include/ flodb/libleveldb.a $(LIBRARIES) -DFLODB_COMPILE

hyperleveldb_bench: bench/bench.c hyperleveldb/.libs/libhyperleveldb.a
	g++ $(CPP_FLAGS) -o $@ $< -Ihyperleveldb/include/ hyperleveldb/.libs/libhyperleveldb.a $(LIBRARIES) -DHYPERLEVELDB_COMPILE

rocksdb_bench: bench/bench.c rocksdb/librocksdb.a
	g++ $(CPP_FLAGS) -o $@ $< -Irocksdb/include/ rocksdb/librocksdb.a $(LIBRARIES) -DROCKSDB_COMPILE

