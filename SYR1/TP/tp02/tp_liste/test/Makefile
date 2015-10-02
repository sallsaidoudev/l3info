# root of Google Test
GTEST_DIR = /share/esir1/prog/google_test
INCDIR    = ../include

# Flags passed to the preprocessor.
CPPFLAGS += -I$(GTEST_DIR)/include -I$(INCDIR)

# Flags passed to the C compiler.
CFLAGS += -g -Wall

# Flags passed to the C++ compiler.
CXXFLAGS += $(CFLAGS)

# libs to link statically
LIBS  =  $(GTEST_DIR)/lib/.libs/libgtest.a $(GTEST_DIR)/lib/.libs/libgtest_main.a

%.o : %.cc %.hh
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $*.o

%.o : %.cpp %.hpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $*.o

all : test_unitaire_list test

test_unitaire_list : test_unitaire_list.o ../obj/list.o
	$(CXX) $(LDFLAGS) -lpthread $^ $(LIBS) -o $@

../obj/list.o : ../src/list.c ../include/list.h
	$(CC) -c -I$(INCDIR) $(CFLAGS) ../src/list.c -o ../obj/list.o

test : test_unitaire_list
	./test_unitaire_list

raz clean :
	-rm *.o *~ test_unitaire_list
