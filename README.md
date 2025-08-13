# BigNum PowerShell Class

⚡ **High-Precision Big Number Arithmetic in PowerShell** ⚡

This project provides **`BigNum`, `BigComplex`, and a preliminary `BigFormula` PowerShell classes** designed for advanced mathematical operations with arbitrary-precision decimal numbers.
It includes a wide set of features: from basic arithmetic to transcendental functions, roots, and famous mathematical and physical constants.

> **Why?**
> PowerShell has no built-in arbitrary-precision decimal type nor complex number handling — but sometimes you need more than `double` or `decimal` for scientific calculations, cryptography, or precise numerical methods.

---

## ✨ Features

✅ Arbitrary-precision arithmetic (`+`, `-`, `*`, `/`, `%`)

✅ Power functions (`Pow` and `ModPow` handles integer & non-integer exponents)

✅ Roots: square root, cube root, **nth root (integer and non-integer)**

✅ Exponential and logarithm (`Exp`, `Ln`, `Log`)

✅ Trigonometric functions (`Sin`, `Cos`, `Tan`, `Csc`, `Sec`, `Cot`)

✅ Inverse Trigonometric functions (`Arcsin`, `Arccos`, `Arctan`, `Atan2`, `Arccsc`, `Arcsec`, `Arccot`)

✅ Hyperbolic Trigonometric functions (`Sinh`, `Cosh`, `Tanh`, `Csch`, `Sech`, `Coth`)

✅ Inverse Hyperbolic Trigonometric functions (`Arcsinh`, `Arccosh`, `Arctanh`, `Arccsch`, `Arcsech`, `Arccoth`)

✅ Main Combinatorial functions (`Permutation`, `Combination`, `CombinationMulti`)

✅ Main Analytic Combinatorial functions (`Pnk`, `Cnk`, `CnkMulti`)

✅ Other functions (`Factorial`, `Gamma`, `EuclideanDiv`, `Min`, `Max`)

✅ Famous mathematical constants with arbitrary precision (`Pi`, `e`, `Tau`, `phi`)

✅ more mathematical constants with 1000 Digits (`EulerMascheroniGamma`, `AperyZeta3`, `CatalanG`, `FeigenbaumA`, `FeigenbaumDelta`)

✅ Physical constants (`c` Speed of Light, `Plank_h`, `Plank_Reduced_h`, `Boltzmann_k`, `G` Gravitational Constant, `Avogadro_Mole`)

✅ Flexible decimal resolution control

✅ Extensive rounding and cropping methods

---

## 🔧 Installation using PowerShell Gallery

You can get this module automaticaly from the PowerShell Gallery as "Powershell-BigNum":

```powershell
Install-Module -Name Powershell-BigNum
```

after installing it, you can make the classes available using the following line either by itself, or adding it in your $PROFILE file.

```powershell
Using module Powershell-BigNum
```

---

## 🛠 Usage Examples

### Basic Operations

```powershell
# PowerShell-style Syntax
$a = New-BigNum 12345
$c = New-BigComplex "42-7.5i"

# DotNet-style Syntax
$b = [BigNum]12345
$d = [BigComplex]"42-7.5i"

$sum = $a + $b
$diff = $a - $b
$product = $a * $b
$quotient = $a / $b
```

### Advanced Functions

```powershell
$val = New-BigNum "2.5"

$pow = [BigNum]::Pow($val, 3)
$sqrt = [BigNum]::Sqrt($val)
$cbrt = [BigNum]::Cbrt($val)
$nroot = [BigNum]::NthRoot($val, 5)
$exp = [BigNum]::Exp($val)
$ln = [BigNum]::Ln($val)
$log = [BigNum]::Log(10,$val)
```

### Constants

```powershell
$pi = [BigNum]::Pi(100)   # Pi at 100 decimal precision
$e = [BigNum]::e(100)     # Euler's number at 100 decimals
$tau = [BigNum]::Tau(100) # Tau at 100 decimal precision
$c = [BigNum]::c()        # Speed of light (exact)
```

### BigFormula syntax

```powershell
$formula1 = [BigFormula]"42! + sqrt(8.5)"           # New Formula with default decimal precision output
$formula1.Evaluate()                                # Compute formula1 with no extra parameters
$formula1.EvaluateR()                               # Compute formula1 but restricted to real numbers and functions
$formula1                                           # Display the formula, rebuilt from the internal representation
$formula2 = [BigFormula]::new("x! + sqrt(y)", 10)   # New Formula with two variables and 10 decimal precision output
$formula2.Evaluate(@{x = 25; y = "15.007"})         # Compute formula2 with x and y as auto-casted BigNum extra parameters
$formula3 = [BigFormula]"2exp(3i*Tau/2)"            # New Formula with implicit multiplications
$formula3                                           # Display the formula and reveal implicit multiplications
```

### BigFormula Nested complex Binet example

```powershell
# Create the "A" value in the generalised Binet Formula
$BinetA = [BigFormula]"(UOne - (UZero * Psi))/(Sqrt(5))"
# Create the "B" value in the generalised Binet Formula
$BinetB = [BigFormula]"((UZero * Phi) - UOne)/(Sqrt(5))"
# Formula for the full Complex Binet Formula
$BinetUz = [BigFormula]"(A * Pow(Phi, z))+(B * Pow(Psi, z))"

# Nest formulas and inject parameters for Binet Formula
# UZero and UOne are the first two terms of the sequence
# -> {0,1} corresponds to Fibonacci Sequence
# -> {2,1} corresponds to Lucas Number Sequence

# Generate the first ten terms of Fibonacci Sequence
for($i=0;$i -le 10;$i += 1) {$BinetUz.Evaluate(@{A=$BinetA ; B=$BinetB ; UZero=0 ; UOne=1 ; z=$i})}

# Generate the first ten terms of Lucas Number Sequence
for($i=0;$i -le 10;$i += 1) {$BinetUz.Evaluate(@{A=$BinetA ; B=$BinetB ; UZero=2 ; UOne=1 ; z=$i})}
```

---

## ⚙️ Resolution Control

Each `BigNum` instance has a **maximum decimal resolution**.
* list of cloning methods to alter the maximum decimal resolution (all create a new instance):
  * `.CloneWithNewResolution()` → Make "maximum decimal resolution" to match "val", and truncate if needed
  * `.CloneAndRoundWithNewResolution()` → Reduce "maximum decimal resolution" to match "val", and round if needed
  * `.CloneWithAddedResolution()` → Make "maximum decimal resolution" increase by "val"
  * `.CloneWithAdjustedResolution()` → Shorten the "maximum decimal resolution" to the current decimal expansion lenght
  * `.CloneAndReducePrecisionBy()` → Reduce "maximum decimal resolution" by "val", and round if needed

* list of Rounding methods (all create new instances, and leave the internal maximum decimal resolution untouched):
  * `.Round()` → Round to the the closest value of desired length, 0,5 are rounded away from zero
  * `.Ceiling()` → Round to a bigger or equal value of desired length
  * `.Floor()` → Round to a lower or equal value of desired length
  * `.Truncate()` → Crop to the desired length without rounding
  * `.RoundAwayFromZero()` → Round away from zero to the desired length

Example:

```powershell
$highRes = $val.ChangeResolution(200)
$cropped = $highRes.Crop(50)
$rounded = $cropped.Round(20)
```

---

## 🚀 Advanced Features

### Integer & Non-Integer Nth Roots

Handles both efficiently:

```powershell
# Integer root (fast path)
$result = [BigNum]::NthRootInt($val, 7)

# General root (including non-integer)
$result = [BigNum]::NthRoot($val, "2.5")
```

### Cached Constants

For performance, numerous constants are cached internally.
To clear them:

```powershell
[BigNum]::ClearCachedPi()
[BigNum]::ClearCachedTau()
[BigNum]::ClearCachedE()
[BigNum]::ClearCachedPhi()
[BigNum]::ClearCachedBernoulliNumberB() # Hashtable
[BigNum]::ClearCachedEulerMascheroniGamma()
[BigNum]::ClearCachedSqrt2()
[BigNum]::ClearCachedSqrt3()
[BigNum]::ClearCachedCbrt2()
[BigNum]::ClearCachedCbrt3()
[BigNum]::ClearAllCachedValues()
```

---

## 💡 Notes

* Negative numbers:

  * even-valued `NthRoot()` and `Sqrt()` reject negative input. Use `[BigComplex]::NthRoot()` and `[BigComplex]::Sqrt()` for complex outputs.
  * `Pow()` does not support complex results (negative base with non-integer exponent). Use `[BigComplex]::Pow()` for complex outputs.

* Internal computations use temporarily higher precision for stability and truncate the result to match the input resolution.

* Integer exponents are optimized internally for performance; non-integer exponents use general methods like `Exp(Ln(x) * n)`.

---

## 🧪 Planned Improvements

* TBD

---

## 🤝 Contributing

This is an experimental PowerShell class.
Feel free to open issues or pull requests if you want to contribute!

---

## 📜 License

MIT License — free to use, modify, and distribute.

