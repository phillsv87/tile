tile-out:
	xcodebuild
	cp -r ./build/Release tile-out

install: uninstall clean-out tile-out
	cp -r ./tile-out /usr/local/opt/tile
	ln -s /usr/local/opt/tile/tile /usr/local/bin/tile

uninstall:
	rm -f /usr/local/bin/tile
	rm -rf /usr/local/opt/tile

clean-out:
	rm -rf ./tile-out

clean: clean-out
	rm -rf ./build
