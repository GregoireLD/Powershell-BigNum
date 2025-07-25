# BigNum PowerShell Class

⚡ **High-Precision Big Number Arithmetic in PowerShell** ⚡

This project provides **`BigNum` and `BigComplex` PowerShell class** designed for advanced mathematical operations with arbitrary-precision decimal numbers.
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

✅ Other functions functions (`Factorial`, `Gamma`, `EuclideanDiv`, `Min`, `Max`)

✅ Famous mathematical constants with arbitrary precision (`Pi`, `e`, `Tau`, `phi`)

✅ more mathematical constants with 1000 Digits (`EulerMascheroniGamma`, `AperyZeta3`, `CatalanG`, `FeigenbaumA`, `FeigenbaumDelta`)

✅ Physical constants (speed of light, Planck constant, Avogadro, etc.)

✅ Flexible decimal resolution control

✅ Extensive rounding and cropping methods

---

## 🔧 Installation

To use this module, the "Powershell-BigNum" folder, contaning both the psm1
and the psd1 files, must be in one of your default Powershell Modules folder.
You can check what they are using :

```powershell
Write-Output $env:PSModulePath
```

alternatively, you can also manually enable it using the folowing command :

```powershell
Import-Module <Path_to_the_Powershell-BigNum.psm1_file>
```

---

## 🛠 Usage Examples

### Basic Operations

```powershell
# PowerShell-style Syntax
$a = New-BigNum 12345

# DotNet-style Syntax
$b = [BigNum]6789
$c = [BigComplex]"42-5i"

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
$nroot = [BigNum]::NthRoot($val, [BigNum]5)
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

---

## ⚙️ Resolution Control

Each `BigNum` instance has a **maximum decimal resolution**.
* list of cloning methods to alter the maximum decimal resolution (all create a new instance):
  * `.CloneWithNewResolution()` → Make "maximum decimal resolution" to match "val", and truncate if needed
  * `.CloneWithAddedResolution()` → Make "maximum decimal resolution" increase by "val"
  * `.CloneWithAdjustedResolution()` → Shorten the "maximum decimal resolution" to the current decimal expansion lenght
  * `.CloneAndReducePrecisionBy()` → Reduce "maximum decimal resolution" by "val", and round if needed

* list of Rounding methods (all create new instances, and leave maximum decimal resolution untouched):
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
$result = [BigNum]::NthRoot($val, [BigNum]"2.5")
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

* Complex number support (Preliminary works started on the BigComplex class)
* Performance optimizations

---

## 🤝 Contributing

This is an experimental PowerShell class.
Feel free to open issues or pull requests if you want to contribute!

---

## 📜 License

MIT License — free to use, modify, and distribute.

