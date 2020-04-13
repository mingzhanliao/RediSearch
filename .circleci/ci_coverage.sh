#!/bin/bash
set -e
set -x

if [ -z "$CI_CONCURRENCY" ];
then
    CI_CONCURRENCY=8
fi

./.circleci/ci_get_deps.sh
apt-get update
apt-get -y install lcov curl gcovr

mkdir build-coverage
cd build-coverage
cmake .. -DCMAKE_BUILD_TYPE=DEBUG \
    -DRS_RUN_TESTS=ON \
    -DUSE_COVERAGE=ON

make -j20 USE_COVERAGE=1

cat >rltest.config <<EOF
--unix
EOF

./lcov-init.sh
ctest -j20
./lcov-capture.sh coverage.info
bash <(curl -s https://codecov.io/bash) -f coverage.info
lcov -l coverage.info --rc lcov_branch_coverage=1
genhtml --legend -o report coverage.info > /dev/null 2>&1