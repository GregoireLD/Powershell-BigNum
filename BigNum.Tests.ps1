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
            ([BigNum]([float]3.14)).ToString() | Should -Match "^3[,.]14"
        }
        It "Constructs from negative double" {
            ([BigNum]([float]-7.0)).ToString() | Should -Be "-7"
        }
        It "Constructs from negative decimal" {
            ([BigNum]([decimal]159.42)).ToString() | Should -Match "^159[,.]42"
        }
        It "Constructs from BigInt" {
            ([BigNum]([System.Numerics.BigInteger]"123456789")).ToString() | Should -Be "123456789"
        }
        It "Constructs from string" {
            ([BigNum]"-123ver45.6789cwe01").ToString() | Should -Match "^-12345[,.]678901"
        }
    }

    Context "Basic arithmetic" {
        It "Addition works" {
            (([BigNum]5) + ([BigNum]2)).ToString() | Should -Be "7"
        }
        It "Subtraction works" {
            (([BigNum]5) - ([BigNum]2)).ToString() | Should -Be "3"
        }
        It "Multiplication works" {
            (([BigNum]5) * ([BigNum]2)).ToString() | Should -Be "10"
        }
        It "Division works" {
            (([BigNum]10) / ([BigNum]3)).CloneWithNewResolution(5).ToString() | Should -Match "3[,.]33333"
        }
    }

    Context "Modulus" {
        It "Modulo works with positive ints" {
            (([BigNum]5) % ([BigNum]2)).ToString() | Should -Be "1"
        }
        It "Modulo works with non-ints" {
            (([BigNum]"8765.868") % ([BigNum]"2.6")).ToString() | Should -Match "^1[,.]268"
        }
    }

    Context "IComparable and IEquatable" {
        It "CompareTo works with auto-casting" {
            (([BigNum]"18024756") -gt 42) | Should -Be $true
        }
        It "Modulo works with non-ints" {
            (([BigNum]"8765.868000") -eq ([BigNum]"008765.86800")) | Should -Be $true
        }
    }

    Context "Simple Methods" {
        It "Min between two numbers" {
            [BigNum]::Min(5,15).ToString() | Should -Be "5"
        }
        It "Max between two numbers" {
            [BigNum]::Max(5,15).ToString() | Should -Be "15"
        }
        It "Euclidean Division between two numbers" {
            [BigNum]::EuclideanDiv(17,5).ToString() | Should -Be "3"
        }
    }

    Context "Roots" {
        It "Sqrt of 15" {
            [BigNum]::Sqrt(15).CloneWithNewResolution(5).ToString() | Should -Match "^3[,.]87298"
        }
        It "Cbrt of 15" {
            [BigNum]::Cbrt(15).CloneWithNewResolution(5).ToString() | Should -Match "^2[,.]46621"
        }
        It "4.6th Root of 15" {
            [BigNum]::NthRoot(4.6,([BigNum]15).CloneWithNewResolution(5)).ToString() | Should -Match "^1[,.]80165"
        }
    }

    Context "Exp, Pow, Ln, and Log" {
        It "Exp works with a positive integer" {
            [BigNum]::Exp(5).ToString() | Should -Match "^148[,.]4131591025"
        }
        It "Exp works with a positive non-integer" {
            [BigNum]::Exp("42.42").ToString() | Should -Match "^2647109595645050097[,.]7445140383848065"
        }
        It "Exp works with a negative non-integer" {
            [BigNum]::Exp("-42.42").ToString() | Should -Match "^0[,.]0000000000000000003777705319"
        }
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

    Context "Factorial and Gamma" {
        It "Computes 10! correctly" {
            ([BigNum]::Factorial(10)).ToString() | Should -Be 3628800
        }
        It "Computes (5.5)! with 10 digits correctly" {
            ([BigNum]::Factorial(([BigNum]5.5).CloneWithNewResolution(10))).ToString() | Should -Match "^287[,.]885277815"
        }
        It "Computes Gamma(-4.5) with 10 digits correctly" {
            ([BigNum]::Gamma(([BigNum]"-4.5").CloneWithNewResolution(10))).CloneWithNewResolution(10).ToString() | Should -Match "^-0[,.]0600196013"
        }
    }

    Context "Trigonometry Tests" {
        It "Computes Sin(-5.23) (Sine) correctly" {
            [BigNum]::Sin("-5.23").Truncate(10).ToString() | Should -Match "^0[,.]869003739"
        }
        It "Computes Cos(-5.23) (Cosine) correctly" {
            [BigNum]::Cos("-5.23").Truncate(10).ToString() | Should -Match "^0[,.]4948055189"
        }
        It "Computes Tan(-5.23) (Tangent) correctly" {
            [BigNum]::Tan("-5.23").Truncate(10).ToString() | Should -Match "^1[,.]7562531253"
        }
        It "Computes Csc(-5.23) (Cosecant) correctly" {
            [BigNum]::Csc("-5.23").Truncate(10).ToString() | Should -Match "^1[,.]1507430349"
        }
        It "Computes Sec(-5.23) (Secant) correctly" {
            [BigNum]::Sec("-5.23").Truncate(10).ToString() | Should -Match "^2[,.]0209960515"
        }
        It "Computes Cot(-5.23) (Cotangent) correctly" {
            [BigNum]::Cot("-5.23").Truncate(10).ToString() | Should -Match "^0[,.]5693940045"
        }
        It "Computes Arcsin(0.84) (Inverse Sine) correctly" {
            [BigNum]::Arcsin("0.84").Truncate(10).ToString() | Should -Match "^0[,.]9972832223"
        }
        It "Computes Arccos(-0.42) (Inverse Cosine) correctly" {
            [BigNum]::Arccos("-0.42").Truncate(10).ToString() | Should -Match "^2[,.]0042416468"
        }
        It "Computes Arctan(-5.23) (Inverse Tangent) correctly" {
            [BigNum]::Arctan("5.23").Truncate(10).ToString() | Should -Match "^1[,.]3818720191"
        }
        It "Computes Atan2(0.001,-1.001) (Two-Argument Inverse Tangent) correctly" {
            ([BigNum]::Atan2([BigNum]"0.001",[BigNum]"-1.001")).Truncate(10).ToString() | Should -Match "^3[,.]1405936529"
        }
        It "Computes Arccsc(1.84) (Inverse Cosecant) correctly" {
            [BigNum]::Arccsc("1.84").Truncate(10).ToString() | Should -Match "^0[,.]5745752096"
        }
        It "Computes Arcsec(-1.42) (Inverse Secant) correctly" {
            [BigNum]::Arcsec("-1.42").Truncate(10).ToString() | Should -Match "^2[,.]3521277919"
        }
        It "Computes Arccot(-5.23) (Inverse Cotangent) correctly" {
            [BigNum]::Arccot("5.23").Truncate(10).ToString() | Should -Match "^0[,.]1889243076"
        }
    }

    Context "Trigonometry Tests" {
        It "Computes Sinh(-5.23) (Hyperbolic Sine) correctly" {
            [BigNum]::Sinh("-5.23").Truncate(10).ToString() | Should -Match "^-93[,.]3937249974"
        }
        It "Computes Cosh(-5.13) (Hyperbolic Cosine) correctly" {
            [BigNum]::Cosh("-5.13").Truncate(10).ToString() | Should -Match "^84[,.]5115173026"
        }
        It "Computes Tanh(0.42) (Hyperbolic Tangent) correctly" {
            [BigNum]::Tanh("0.42").Truncate(10).ToString() | Should -Match "^0[,.]396930432"
        }
        It "Computes Csch(-5.23) (Hyperbolic Cosecant) correctly" {
            [BigNum]::Csch("-5.23").Truncate(10).ToString() | Should -Match "^-0[,.]0107073574"
        }
        It "Computes Sech(-0.23) (Hyperbolic Secant) correctly" {
            [BigNum]::Sech("-0.23").Truncate(10).ToString() | Should -Match "^0[,.]9741207235"
        }
        It "Computes Coth(-5.23) (Hyperbolic Cotangent) correctly" {
            [BigNum]::Coth("-5.23").Truncate(10).ToString() | Should -Match "^-1[,.]0000573221"
        }
        It "Computes Arcsinh(0.84) (Hyperbolic Inverse Sine) correctly" {
            [BigNum]::Arcsinh("0.84").Truncate(10).ToString() | Should -Match "^0[,.]7635992217"
        }
        It "Computes Arccosh(3.14) (Hyperbolic Inverse Cosine) correctly" {
            [BigNum]::Arccosh("3.14").Truncate(10).ToString() | Should -Match "^1[,.]8109913489"
        }
        It "Computes Arctanh(-0.42) (Hyperbolic Inverse Tangent) correctly" {
            [BigNum]::Arctanh("-0.42").Truncate(10).ToString() | Should -Match "^-0[,.]4476920235"
        }
        It "Computes Arccsch(0.84) (Hyperbolic Inverse Cosecant) correctly" {
            [BigNum]::Arccsch("0.84").Truncate(10).ToString() | Should -Match "^1[,.]0098618321"
        }
        It "Computes Arcsech(0.42) (Hyperbolic Inverse Secant) correctly" {
            [BigNum]::Arcsech("0.42").Truncate(10).ToString() | Should -Match "^1[,.]5133066884"
        }
        It "Computes Arccoth(-5.23) (Hyperbolic Inverse Cotangent) correctly" {
            [BigNum]::Arccoth("5.23").Truncate(10).ToString() | Should -Match "^0[,.]1935871698"
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
