PATH=/home/thanh/flex_sdk/bin:$PATH
echo "Generating documents"

asdoc -load-config+=asdoc_config.xml -output=../../doc

echo "Completed. Press ENTER to continue..."
read cont
