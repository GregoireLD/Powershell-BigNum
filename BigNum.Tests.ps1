# Requires -Module Pester

Import-Module Pester

Describe "BigNum class unit tests" {

    BeforeAll {
        Import-Module Powershell-BigNum
    }

    Context "Basic constructors" {
        It "Constructs from int" {
            ([BigNum]([int]5)).ToString() | Should -Be "5"
        }
        It "Constructs from float" {
            ([BigNum]3.14).ToString() | Should -Match "^3[,.]14"
        }
        It "Constructs from negative int" {
            ([BigNum]-7).ToString() | Should -Match "^-7"
        }
        It "Constructs from string" {
            ([BigNum]"-123ver45.6789cwe01").ToString() | Should -Match "^-12345[,.]678901"
        }
    }

    Context "Basic arithmetic" {
        It "Addition works" {
            ([BigNum]5 + [BigNum]2).ToString() | Should -Be "7"
        }
        It "Subtraction works" {
            ([BigNum]5 - [BigNum]2).ToString() | Should -Be "3"
        }
        It "Multiplication works" {
            ([BigNum]5 * [BigNum]2).ToString() | Should -Be "10"
        }
        It "Division works" {
            ([BigNum]10 / [BigNum]2).ToString() | Should -Be "5"
        }
    }

    Context "Modulus" {
        It "Modulo works with positive ints" {
            ([BigNum]5 % [BigNum]2).ToString() | Should -Be "1"
        }
        It "Modulo works with non-ints" {
            ([BigNum]"8765.868" % [BigNum]"2.6").ToString() | Should -Match "^1[,.]268"
        }
    }

    Context "Exp Tests" {
        It "Exp works with a positive integer" {
            [BigNum]::Exp(5).ToString() | Should -Match "^148[,.]4131591025"
        }
        It "Exp works with a positive non-integer" {
            [BigNum]::Exp("42.42").ToString() | Should -Match "^2647109595645050097[,.]7445140383848065"
        }
        It "Exp works with a negative non-integer" {
            [BigNum]::Exp("-42.42").ToString() | Should -Match "^0[,.]0000000000000000003777705319"
        }
    }

    Context "Ln and Log Tests" {
        It "Ln works with a positive integer" {
            [BigNum]::Ln(5).ToString() | Should -Match "^1[,.]609437912434"
        }
        It "Ln works with a positive non-integer" {
            [BigNum]::Ln("0.42").ToString() | Should -Match "^-0[,.]8675005677047230"
        }
        It "Ln throws with a negative number" {
            { [BigNum]::Ln("-42.42").ToString() } | Should -Throw
        }
        It "Log works with positive integers" {
            [BigNum]::Log(3,43).ToString() | Should -Match "^3[,.]42359188449767959"
        }
        It "Log works with positive non-integer" {
            [BigNum]::Log("75","0.42").ToString() | Should -Match "^-0[,.]2009271467325899121"
        }
        It "Log throws with a negative base" {
            { [BigNum]::Log("-42.42","412").ToString() } | Should -Throw
        }
    }

    Context "Pow Tests" {
        It "Pow works with positive integers" {
            [BigNum]::Pow(24,3).ToString() | Should -Be "13824"
        }
        It "Pow works with positive non-integers" {
            [BigNum]::Pow(23.1,4.2).ToString() | Should -Match "^533544[,.]09233865606076"
        }
        It "Pow works with negative non-integers" {
            [BigNum]::Pow(-3.3,5).ToString() | Should -Match "^-391[,.]35393"
        }
        It "Pow returns 0 for value of 0" {
            [BigNum]::Pow(0,4213).ToString() | Should -Be "0"
        }
        It "Pow returns 1 for exp of 0" {
            [BigNum]::Pow("-431.43145",0).ToString() | Should -Be "1"
        }
        It "Pow throws for complex output" {
            { [BigNum]::Pow(-3.3,-5.1).ToString() } | Should -Throw
        }
    }

    Context "ModPow Tests" {
        It "Computes 5^3 mod 13 correctly" {
            ([BigNum]::ModPow(5, 3, 13)).ToString() | Should -Be 8  # 5^3 = 125, 125 mod 13 = 8
        }
        It "Computes 2^10 mod 17 correctly" {
            [BigNum]::ModPow(2, 10, 17).ToString() | Should -Be 4  # 2^10 = 1024, 1024 mod 17 = 4
        }
        It "Computes (39.9)^(23.1) mod 13.3 correctly - Decimal path checks (non-crypto fallback)" {
            [BigNum]::ModPow("39.9", "23.1", "13.3").ToString() | Should -Match "^11[,.]6489212644"
        }
        It "Zero exponent returns 1" {
            [BigNum]::ModPow(7, 0, 11).ToString() | Should -Be 1
        }
        It "Zero base returns 0 unless exponent 0" {
            [BigNum]::ModPow(0, 5, 11).ToString() | Should -Be 0
        }
    }

    Context "Factorial Tests" {
        It "Computes 10! correctly" {
            ([BigNum]::Factorial(10)).ToString() | Should -Be 3628800
        }
    }

    Context "Special constants" {
        It "Pi has correct start" {
            [BigNum]::Pi(1042).ToString() | Should -Match "^3[,.]141592"
        }
        It "Tau has correct start" {
            [BigNum]::Tau(1042).ToString() | Should -Match "^6[,.]283185"
        }
        It "e has correct start" {
            [BigNum]::e(1042).ToString() | Should -Match "^2[,.]718281"
        }
        It "Phi has correct start" {
            [BigNum]::Phi(1042).ToString() | Should -Match "^1[,.]618033"
        }
        It "Bernoulli Number B generate correclty" {
            ([BigNum]::BernoulliNumberB(100,10)%100000).ToString() | Should -Match "^92971[,.]8658565857"
        }
        It "Harmonic series Hn generate correclty" {
            [BigNum]::HarmonicSeriesHn(50,10).ToString() | Should -Match "^4[,.]4992053383"
        }
    }
}
