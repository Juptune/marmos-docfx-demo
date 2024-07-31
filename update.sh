# Args:
#  $1 = Absolute path to marmos executable
#
# Example: bash ./update.sh $PWD/../marmos/build/marmos

rm -rf _marmos-output/models/

mkdir -p _marmos-output/repos
mkdir -p _marmos-output/models/phobos
mkdir -p _marmos-output/models/juptune

# Clone Juptune & Phobos
git clone --depth 1 https://github.com/Juptune/juptune _marmos-output/repos/juptune
git clone --depth 1 https://github.com/dlang/phobos _marmos-output/repos/phobos

# Generate marmos models
pushd _marmos-output/models/phobos
for file in $(find "../../repos/phobos/" -name "*.d"); do
    echo "Processing $file"
    $1 generate-generic $file
done
rm __anonymous*.json

popd
pushd _marmos-output/models/juptune
for file in $(find "../../repos/juptune/src/" -name "*.d"); do
    echo "Processing $file"
    $1 generate-generic $file
done
rm __anonymous*.json

# Convert to docfx
popd
cwd=$(pwd)
npx marmos-docfx convert $cwd/_marmos-output/models/phobos/*.json --outputFolder $cwd/src/phobos
npx marmos-docfx convert $cwd/_marmos-output/models/juptune/*.json --outputFolder $cwd/src/juptune

# Build
pushd src
docfx build
rm -rf ../docs
mv _site ../docs