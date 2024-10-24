objects = build/main.o build/console.o build/dimensionInput.o build/mineInput.o build/draw.o build/flagInit.o build/numberSet.o build/chording.o build/zeroChain.o build/gameEnd.o build/flagCount.o
.PHONY: clean

kaboom: $(objects)
	$(CC) -no-pie -o "$@" $^

build:
	mkdir build

build/%.o: %.s | build
	$(CC) -no-pie -c -o "$@" "$<"

clean:
	rm -rf kaboom build
