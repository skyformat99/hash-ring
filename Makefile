CC = gcc
override CFLAGS += -O3 -Wall -fPIC
LDFLAGS =
OBJECTS = build/hash_ring.o build/sha1.o build/sort.o build/md5.o
TEST_OBJECTS = build/hash_ring_test.o
ifdef PREFIX
	prefix=$(PREFIX)
else
	prefix=/usr/local
endif

ifeq ($(OS), Darwin)
	SHARED_LIB = build/libhashring.so
else
	SHARED_LIB = build/libhashring.dylib
endif

lib: $(OBJECTS)
	$(CC) $(CFLAGS) $(LDFLAGS) $(OBJECTS) -o $(SHARED_LIB) -shared

test : lib $(TEST_OBJECTS)
	mkdir -p bin
	$(CC) $(CFLAGS) $(LDFLAGS) $(TEST_OBJECTS) -lhashring -L./build -o bin/hash_ring_test
	bin/hash_ring_test

bindings: erl java python

erl:
	./rebar compile
	
java:
	cd lib/java && gradle jar

python:
	cd lib/python && ./setup.py bdist

build/%.o : %.c
	$(CC) $(CFLAGS) -c $< -o $@
	
clean:
	rm -rf $(OBJECTS) $(TEST_OBJECTS) $(SHARED_LIB)
	
install: lib
	mkdir -p $(prefix)/lib
	mkdir -p $(prefix)/include
	cp -f $(SHARED_LIB) $(prefix)/lib/
	cp hash_ring.h $(prefix)/include/
