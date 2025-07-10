# Powershell-BigNum
Powershell / DotNet [BigNum] arbitrary-precision decimal Class, based on the BigInt class.
Allow signed decimal storage and calculation of arbitrary lenght and precision.
Most usual operators are implemented : addition, substraction, multiplication, division, modulo, base-10 left shift, base-10 right shift.
This class implements "IComparable", and as such, implements -eq, -lt, -le, -gt, and -ge.
[BigNum] can be rounded with 5 functions : Round (nearest half), RoundUp (always bigger), RoundUp (always smaller), RoundTowardZero (always closer to zero), RoundAwayFromZero (always away from zero).

## Samples :

### Auto-Loading :

To use this module, the "Powershell-BigNum" folder, contaning both the psm1
and the psd1 files, must be in one of your default Powershell Modules folder.
You can check what they are using :

```powershell
Write-Output $env:PSModulePath
```

### Manual Loading :

You can also manually enable it using the folowing command :

```powershell
Import-Module <Path_to_the_Powershell-BigNum.psm1_file>
```

### Various Samples :

#### Instantiate and store a new [BigNum] object using an explicit cast. <123> can be of type : Integer, Decimal, Float, Double, BigInteger, String
```powershell
$val = [BigNum] <123>
```

#### Alternate way using a Cmdlet
```powershell
$val = New-BigNum <123>
```

#### Get the integer part of the number
```powershell
$val.Int()
```

#### Dividing a BigNum by an implicitly casted integer (by default, trims at 100 decimal digits)
```powershell
$val = [BigNum]10 / 3
```

#### Instantiating a BigNum with a different decimal resolution. BigNum are immutable so changing the resolution clones the BigNum to a new object.
```powershell
$val = ([BigNum]10).ChangeResolution(1000) / 3
```

#### Rounding example
```powershell
$val = [BigNum]10
$val = $val.ChangeResolution(1000)
$val = $val / 3
$val = $val.Round(999)
$val
```

