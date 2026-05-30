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

function LibriSpeech_clean360() {
	if ! test -e $librispeech_dir/train-clean-360; then
		echo "Download LibriSpeech/train-clean-360 into $storage_dir"
		wget -c --tries=0 --read-timeout=20 http://www.openslr.org/resources/12/train-clean-360.tar.gz -P $storage_dir
		tar -xzf $storage_dir/train-clean-360.tar.gz -C $storage_dir
		rm -rf $storage_dir/train-clean-360.tar.gz
	fi
}

function LibriSpeech_dev_clean() {
	if ! test -e $librispeech_dir/dev-clean; then
		echo "Download LibriSpeech/dev-clean into $storage_dir"
		wget -c --tries=0 --read-timeout=20 http://www.openslr.org/resources/12/dev-clean.tar.gz -P $storage_dir
		tar -xzf $storage_dir/dev-clean.tar.gz -C $storage_dir
		rm -rf $storage_dir/dev-clean.tar.gz
	fi
}

function LibriSpeech_test_clean() {
	if ! test -e $librispeech_dir/test-clean; then
		echo "Download LibriSpeech/test-clean into $storage_dir"
		wget -c --tries=0 --read-timeout=20 http://www.openslr.org/resources/12/test-clean.tar.gz -P $storage_dir
		tar -xzf $storage_dir/test-clean.tar.gz -C $storage_dir
		rm -rf $storage_dir/test-clean.tar.gz
	fi
}

LibriSpeech_clean100 &
LibriSpeech_clean360 &
LibriSpeech_dev_clean &
LibriSpeech_test_clean &

wait

# Path to python
if command -v python >/dev/null 2>&1; then
  python_path=python
elif command -v python3 >/dev/null 2>&1; then
  python_path=python3
else
  echo "Neither python nor python3 was found in PATH."
  exit 1
fi

metadata_dir=metadata/Libri2Mix
$python_path scripts/create_librimix_from_metadata.py --librispeech_dir $librispeech_dir \
  --metadata_dir $metadata_dir \
  --librimix_outdir $librimix_outdir \
  --n_src 2 \
  --subsets train-100 train-360 dev test \
  --freqs 8k \
  --modes min \
  --types mix_clean
