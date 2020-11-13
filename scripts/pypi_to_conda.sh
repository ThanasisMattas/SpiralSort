#!/bin/bash
# script: pypi_to_conda.sh
# ------------------------
# Uploads a package to anaconda cloud, if it is already on pypi.org.
#
# You can pass 1 argument with the name of the package, as it is on pypi.org.
#
# How to install prerequisites:
# $ conda install conda-build anaconda-client -y
#
# Examples:
# $ anaconda login
# $ pypi_to_conda.sh
# $ pypi_to_conda.sh <pkg>
# $ pypi_to_conda.sh "<pkg> --version <version>"
if [ $# -eq 0 ]; then
  # default
  pkg="mattflow"
else
  pkg=$1
fi

python_versions=(3.7 3.8 3.9)

mkdir build
cd build
# Generates the meta.yml recipe, drawing all necessary info from the pypi repo.
conda skeleton pypi $pkg

# Build for all specified python versions.
for v in ${python_versions[@]}; do
  conda build --python $v $pkg
done

# In case pkg string holds --version, keep only the package name.
pkg=$(echo $pkg | head -n1 | cut -d " " -f1)

# Delete ouput_dir, if it exists, not to accidentally upload stuff.
if [ -d /output_dir ]; then
  rm -rf /output_dir
fi

# Convert the package for all platforms
output_tar=$(conda build $pkg --output)
conda convert --platform all $output_tar -o output_dir/

# Upload platformwise packages to anaconda cloud
for arch_dir in output_dir/*; do
  for arch_tar in $arch_dir/*.tar.bz2; do
    anaconda upload $arch_tar
  done
done

# clean the tars created
conda build purge
# Remove the build folder
cd ../
rm -rf build/
echo "Package $pkg was successfully uploaded to anaconda cloud."
