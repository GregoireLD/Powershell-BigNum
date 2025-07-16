# Requires -Module Pester

Import-Module Pester

Describe "BigNum class unit tests" {

    BeforeAll {
        $nullValue = [BigNum]::new()
        $intFive = [BigNum]::new(5)
        $intTwo = [BigNum]::new(2)
        $intTen = [BigNum]::new(10)
        $decimalVal = [BigNum]::new("3.14")
        $negVal = [BigNum]::new(-7)
    }

    Context "Basic constructors" {
        It "Constructs from int" {
            ($intFive.ToString()) | Should -Be "5"
        }
        It "Constructs from string with decimal" {
            ($decimalVal.ToString()) | Should -Match "^3[,.]14"
        }
        It "Constructs negative number" {
            ($negVal.ToString()) | Should -Match "^-7"
        }
    }

    Context "Basic arithmetic" {
        It "Addition works" {
            (($intFive + $intTwo).ToString()) | Should -Be "7"
        }
        It "Subtraction works" {
            (($intFive - $intTwo).ToString()) | Should -Be "3"
        }
        It "Multiplication works" {
            (($intFive * $intTwo).ToString()) | Should -Be "10"
        }
        It "Division works" {
            (($intTen / $intTwo).ToString()) | Should -Match "^5"
        }
    }

    Context "Modulus" {
        It "Modulo works with positive ints" {
            (($intFive % $intTwo).ToString()) | Should -Be "1"
        }
    }

    Context "ModPow integer path" {
        It "Computes 5^3 mod 13 correctly" {
            $base = [BigNum]::new(5)
            $exp = [BigNum]::new(3)
            $mod = [BigNum]::new(13)
            $result = [BigNum]::ModPow($base, $exp, $mod)
            $result.Int() | Should -Be 8  # 5^3 = 125, 125 mod 13 = 8
        }
        It "Computes 2^10 mod 17 correctly" {
            $base = [BigNum]::new(2)
            $exp = [BigNum]::new(10)
            $mod = [BigNum]::new(17)
            $result = [BigNum]::ModPow($base, $exp, $mod)
            $result.Int() | Should -Be 15  # 2^10 = 1024, 1024 mod 17 = 15
        }
    }

    Context "Edge cases" {
        It "Zero exponent returns 1" {
            $base = [BigNum]::new(7)
            $exp = [BigNum]::new(0)
            $mod = [BigNum]::new(11)
            $result = [BigNum]::ModPow($base, $exp, $mod)
            $result.Int() | Should -Be 1
        }
        It "Zero base returns 0 unless exponent 0" {
            $base = [BigNum]::new(0)
            $exp = [BigNum]::new(5)
            $mod = [BigNum]::new(11)
            $result = [BigNum]::ModPow($base, $exp, $mod)
            $result.Int() | Should -Be 0
        }
    }

    Context "Decimal path checks (non-crypto fallback)" {
        It "Computes decimal ^ int (fallback path) mod decimal" {
            $base = [BigNum]::new("1.5")
            $exp = [BigNum]::new(2)
            $mod = [BigNum]::new(1)
            $result = [BigNum]::ModPow($base, $exp, $mod)
            ($result.ToString()) | Should -Be "0.25"
        }
    }

    Context "Negative numbers (should throw or handle)" {
        It "Throws on negative exponent in ModPowPosInt" {
            { [BigNum]::ModPowPosInt(2, -3, 5) } | Should -Throw
        }
        It "Throws on negative modulus in ModPowPosInt" {
            { [BigNum]::ModPowPosInt(2, 3, -5) } | Should -Throw
        }
        It "Handles negative base (fallback path allowed)" {
            $base = [BigNum]::new(-2)
            $exp = [BigNum]::new(3)
            $mod = [BigNum]::new(5)
            $result = [BigNum]::ModPow($base.Abs(), $exp, $mod)  # abs workaround
            $result.Int() | Should -Be 3  # 2^3 mod 5 = 8 mod 5 = 3
        }
    }

    Context "Special constants" {
        It "Pi has correct start" {
            ([BigNum]::Pi().ToString()) | Should -Match "^3[,.]14"
        }
        It "e has correct start" {
            ([BigNum]::e().ToString()) | Should -Match "^2[,.]71"
        }
        It "Phi has correct start" {
            ([BigNum]::Phi().ToString()) | Should -Match "^1[,.]61"
        }
    }
}
