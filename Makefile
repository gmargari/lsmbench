BINARIES = leveldb_bench rangedb_bench flodb_bench hyperleveldb_bench bashodb_bench rocksdb_bench triad_bench
CPP_FLAGS = -Wall -Wno-sign-compare -std=c++11
LIBRARIES = -lpthread -pthread -lsnappy
#MAKE_JOBS = -j 4  # Uncomment if you want to use multiple parallel jobs

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

bashodb/libleveldb.a:
	cd bashodb; make $(MAKE_JOBS)

rocksdb/librocksdb.a:
	cd rocksdb; make $(MAKE_JOBS) static_lib

triad/librocksdb.a:
	cd triad; make $(MAKE_JOBS) static_lib

leveldb_bench: bench/bench.c leveldb/out-static/libleveldb.a
	g++ $(CPP_FLAGS) -o $@ $^ -Ileveldb/include/ $(LIBRARIES) -DLEVELDB_COMPILE

rangedb_bench: bench/bench.c rangedb/libleveldb.a
	g++ $(CPP_FLAGS) -o $@ $^ -Irangedb/include/ $(LIBRARIES) -DRANGEDB_COMPILE

flodb_bench: bench/bench.c flodb/libleveldb.a
	g++ $(CPP_FLAGS) -o $@ $^ -Iflodb/include/ $(LIBRARIES) -DFLODB_COMPILE

hyperleveldb_bench: bench/bench.c hyperleveldb/.libs/libhyperleveldb.a
	g++ $(CPP_FLAGS) -o $@ $^ -Ihyperleveldb/include/ $(LIBRARIES) -DHYPERLEVELDB_COMPILE

bashodb_bench: bench/bench.c bashodb/libleveldb.a
	g++ $(CPP_FLAGS) -o $@ $^ -Ibashodb/include/ -Ibashodb $(LIBRARIES) -DBASHODB_COMPILE

rocksdb_bench: bench/bench.c rocksdb/librocksdb.a
	g++ $(CPP_FLAGS) -o $@ $^ -Irocksdb/include/ $(LIBRARIES) -DROCKSDB_COMPILE

triad_bench: bench/bench.c triad/librocksdb.a
	g++ $(CPP_FLAGS) -o $@ $^ -Itriad/include/ $(LIBRARIES) -DTRIAD_COMPILE

