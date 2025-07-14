# BigNum PowerShell Class

⚡ **High-Precision Big Number Arithmetic in PowerShell** ⚡

This project provides a **`BigNum` PowerShell class** designed for advanced mathematical operations with arbitrary-precision decimal numbers.
It includes a wide set of features: from basic arithmetic to transcendental functions, roots, and famous mathematical and physical constants.

> **Why?**
> PowerShell has no built-in arbitrary-precision decimal type — but sometimes you need more than `double` or `decimal` for scientific calculations, cryptography, or precise numerical methods.

---

## ✨ Features

✅ Arbitrary-precision arithmetic (`+`, `-`, `*`, `/`, `%`)

✅ Power functions (`Pow`, handles integer & non-integer exponents)

✅ Roots: square root, cube root, **nth root (integer and non-integer)**

✅ Exponential and logarithm (`Exp`, `Ln`, `Log`)

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
$log = [BigNum]::Ln($val)
$log = [BigNum]::Log($val,3)
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

* `.ChangeResolution()` → create a new instance with adjusted working precision
* `.Crop()` → create a new instance croped to the desired length without rounding nor changing the resolution
* Rounding methods: `.Round()`, `.RoundUp()`, `.RoundDown()`, `.RoundTowardZero()`, `.RoundAwayFromZero()`

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

For performance, Pi, Tau, and e are cached internally.
To clear them:

```powershell
[BigNum]::ClearCachedPi()
[BigNum]::ClearCachedTau()
[BigNum]::ClearCachedE()
```

---

## 💡 Notes

* Negative numbers:

  * `Sqrt()` and even `NthRootInt()` reject negative input.
  * `Pow()` does not support complex results (negative base with non-integer exponent).

* Internal computations use temporarily higher precision for stability and crop the result.

* Integer exponents are optimized internally for performance; non-integer exponents use general methods like `Exp(Log(x) * n)`.

---

## 🧪 Planned Improvements

* Modular exponentiation
* Complex number support
* Trigonometric functions
* Performance optimizations (possible C# or parallelization)

---

## 🤝 Contributing

This is an experimental PowerShell class.
Feel free to open issues or pull requests if you want to contribute!

---

## 📜 License

MIT License — free to use, modify, and distribute.

