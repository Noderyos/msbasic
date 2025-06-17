OUT_DIR=out
OUTPUT=$(OUT_DIR)/rom.bin
TARGET=noderyos

rom.bin: msbasic.s
	@mkdir -p $(OUT_DIR)
	ca65 -D $(TARGET) msbasic.s -o $(OUT_DIR)/rom.o
	ld65 -C $(TARGET).cfg $(OUT_DIR)/rom.o -o $(OUTPUT) -Ln $(OUT_DIR)/rom.lbl

flash: rom.bin
	minipro -p "AT28C256" -uP -w $(OUTPUT)

clean:
	rm -rf $(TMPDIR) $(OUTPUT)

