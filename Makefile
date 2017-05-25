all: tm

tm:
	scheme simu.ss		#debug on , tape size 100

test: test.ss
	cp test.ss test
	chmod 755 test
	./test

clean:
	rm test
