#!/bin/bash
set -eu  # Exit on error

storage_dir=$1
librispeech_dir=$storage_dir/LibriSpeech
wham_dir=$storage_dir/wham_noise
librimix_outdir=$storage_dir/

function LibriSpeech_clean100() {
	if ! test -e $librispeech_dir/train-clean-100; then
		echo "Download LibriSpeech/train-clean-100 into $storage_dir"
		# If downloading stalls for more than 20s, relaunch from previous state.
		wget -c --tries=0 --read-timeout=20 http://www.openslr.org/resources/12/train-clean-100.tar.gz -P $storage_dir
		tar -xzf $storage_dir/train-clean-100.tar.gz -C $storage_dir
		rm -rf $storage_dir/train-clean-100.tar.gz
	fi
}

LibriSpeech_clean100 &

wait

# Path to python
python_path=python

metadata_dir=metadata/Libri2Mix
$python_path scripts/create_librimix_from_metadata.py --librispeech_dir $librispeech_dir \
  --metadata_dir $metadata_dir \
  --librimix_outdir $librimix_outdir \
  --n_src 2 \
  --subsets train-100 \
  --freqs 8k \
  --modes min \
  --types mix_clean
