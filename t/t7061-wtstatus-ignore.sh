#!/bin/sh

test_description='git-status ignored files'

. ./test-lib.sh

cat >expected <<\EOF
?? .gitignore
?? actual
?? expected
?? untracked/
!! untracked/ignored
EOF

test_expect_success 'status untracked directory with --ignored' '
	echo "ignored" >.gitignore &&
	mkdir untracked &&
	: >untracked/ignored &&
	: >untracked/uncommitted &&
	git status --porcelain --ignored >actual &&
	test_cmp expected actual
'

test_expect_success 'same with gitignore starting with BOM' '
	printf "\357\273\277ignored\n" >.gitignore &&
	mkdir -p untracked &&
	: >untracked/ignored &&
	: >untracked/uncommitted &&
	git status --porcelain --ignored >actual &&
	test_cmp expected actual
'

cat >expected <<\EOF
?? .gitignore
?? actual
?? expected
?? untracked/uncommitted
!! untracked/ignored
EOF

test_expect_success 'status untracked directory with --ignored -u' '
	git status --porcelain --ignored -u >actual &&
	test_cmp expected actual
'
cat >expected <<\EOF
?? untracked/uncommitted
!! untracked/ignored
EOF

test_expect_success 'status prefixed untracked directory with --ignored' '
	git status --porcelain --ignored untracked/ >actual &&
	test_cmp expected actual
'

cat >expected <<\EOF
?? untracked/uncommitted
!! untracked/ignored
EOF

test_expect_success 'status prefixed untracked sub-directory with --ignored -u' '
	git status --porcelain --ignored -u untracked/ >actual &&
	test_cmp expected actual
'

cat >expected <<\EOF
?? .gitignore
?? actual
?? expected
!! ignored/
EOF

test_expect_success 'status ignored directory with --ignore' '
	rm -rf untracked &&
	mkdir ignored &&
	: >ignored/uncommitted &&
	git status --porcelain --ignored >actual &&
	test_cmp expected actual
'

cat >expected <<\EOF
?? .gitignore
?? actual
?? expected
!! ignored/uncommitted
EOF

test_expect_success 'status ignored directory with --ignore -u' '
	git status --porcelain --ignored -u >actual &&
	test_cmp expected actual
'

cat >expected <<\EOF
?? .gitignore
?? actual
?? expected
EOF

test_expect_success 'status empty untracked directory with --ignore' '
	rm -rf ignored &&
	mkdir untracked-ignored &&
	mkdir untracked-ignored/test &&
	git status --porcelain --ignored >actual &&
	test_cmp expected actual
'

cat >expected <<\EOF
?? .gitignore
?? actual
?? expected
EOF

test_expect_success 'status empty untracked directory with --ignore -u' '
	git status --porcelain --ignored -u >actual &&
	test_cmp expected actual
'

cat >expected <<\EOF
?? .gitignore
?? actual
?? expected
!! untracked-ignored/
EOF

test_expect_success 'status untracked directory with ignored files with --ignore' '
	: >untracked-ignored/ignored &&
	: >untracked-ignored/test/ignored &&
	git status --porcelain --ignored >actual &&
	test_cmp expected actual
'

cat >expected <<\EOF
?? .gitignore
?? actual
?? expected
!! untracked-ignored/ignored
!! untracked-ignored/test/ignored
EOF

test_expect_success 'status untracked directory with ignored files with --ignore -u' '
	git status --porcelain --ignored -u >actual &&
	test_cmp expected actual
'

cat >expected <<\EOF
?? .gitignore
?? actual
?? expected
EOF

test_expect_success 'status ignored tracked directory with --ignore' '
	rm -rf untracked-ignored &&
	mkdir tracked &&
	: >tracked/committed &&
	git add tracked/committed &&
	git commit -m. &&
	echo "tracked" >.gitignore &&
	git status --porcelain --ignored >actual &&
	test_cmp expected actual
'

cat >expected <<\EOF
?? .gitignore
?? actual
?? expected
EOF

test_expect_success 'status ignored tracked directory with --ignore -u' '
	git status --porcelain --ignored -u >actual &&
	test_cmp expected actual
'

cat >expected <<\EOF
?? .gitignore
?? actual
?? expected
EOF

test_expect_success 'status ignored tracked directory and ignored file with --ignore' '
	echo "committed" >>.gitignore &&
	git status --porcelain --ignored >actual &&
	test_cmp expected actual
'

cat >expected <<\EOF
?? .gitignore
?? actual
?? expected
EOF

test_expect_success 'status ignored tracked directory and ignored file with --ignore -u' '
	git status --porcelain --ignored -u >actual &&
	test_cmp expected actual
'

cat >expected <<\EOF
?? .gitignore
?? actual
?? expected
!! tracked/uncommitted
EOF

test_expect_success 'status ignored tracked directory and uncommitted file with --ignore' '
	echo "tracked" >.gitignore &&
	: >tracked/uncommitted &&
	git status --porcelain --ignored >actual &&
	test_cmp expected actual
'

cat >expected <<\EOF
?? .gitignore
?? actual
?? expected
!! tracked/uncommitted
EOF

test_expect_success 'status ignored tracked directory and uncommitted file with --ignore -u' '
	git status --porcelain --ignored -u >actual &&
	test_cmp expected actual
'

cat >expected <<\EOF
?? .gitignore
?? actual
?? expected
!! tracked/ignored/
EOF

test_expect_success 'status ignored tracked directory with uncommitted file in untracked subdir with --ignore' '
	rm -rf tracked/uncommitted &&
	mkdir tracked/ignored &&
	: >tracked/ignored/uncommitted &&
	git status --porcelain --ignored >actual &&
	test_cmp expected actual
'

cat >expected <<\EOF
?? .gitignore
?? actual
?? expected
!! tracked/ignored/uncommitted
EOF

test_expect_success 'status ignored tracked directory with uncommitted file in untracked subdir with --ignore -u' '
	git status --porcelain --ignored -u >actual &&
	test_cmp expected actual
'

cat >expected <<\EOF
?? .gitignore
?? actual
?? expected
!! tracked/ignored/uncommitted
EOF

test_expect_success 'status ignored tracked directory with uncommitted file in tracked subdir with --ignore' '
	: >tracked/ignored/committed &&
	git add -f tracked/ignored/committed &&
	git commit -m. &&
	git status --porcelain --ignored >actual &&
	test_cmp expected actual
'

cat >expected <<\EOF
?? .gitignore
?? actual
?? expected
!! tracked/ignored/uncommitted
EOF

test_expect_success 'status ignored tracked directory with uncommitted file in tracked subdir with --ignore -u' '
	git status --porcelain --ignored -u >actual &&
	test_cmp expected actual
'

cat >expected <<\EOF
!! tracked/submodule/
EOF

test_expect_success 'status ignores submodule in excluded directory' '
	git init tracked/submodule &&
	(
		cd tracked/submodule &&
		test_commit initial
	) &&
	git status --porcelain --ignored -u tracked/submodule >actual &&
	test_cmp expected actual
'

cat >expected <<\EOF
?? .gitignore
?? actual
?? expected
!! tracked/ignored/uncommitted
!! tracked/submodule/
EOF

test_expect_success 'status ignored with always_exclude' '
	echo "always_excluded" >.git/info/always_exclude &&
	: >always_excluded &&
	git status --porcelain --ignored >actual &&
	test_cmp expected actual
'

test_done
