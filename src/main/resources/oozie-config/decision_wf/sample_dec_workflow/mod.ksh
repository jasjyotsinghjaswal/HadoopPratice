inp=$1
opt=$(( inp % 2))

if [ ${opt} -eq 0 ];
then
echo "output=Even"
else
echo "output=Odd"
fi