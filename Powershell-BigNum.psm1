
#region Classes

class BigComplex : System.IFormattable, System.IComparable, System.IEquatable[object] {

	hidden [BigNum] $realPart
	hidden [BigNum] $imaginaryPart
	static hidden [String] $iChar = [char]::ConvertFromUtf32(0x1d456)
	
	#region Constructors

	# BigNum : (BigNum,BigNum) Standard Constructor with all possible parameters.
	BigComplex([BigNum]$ar,[BigNum]$bi) {
		$this.Init($ar,$bi)
    }

	# BigNum : (BigNum) Standard Constructor for a pure real number.
	BigComplex([BigNum]$ar) {
		$this.Init($ar,0)
    }

	# BigNum : (BigInteger,BigInteger) Standard Constructor for a BigInteger based complex number.
	BigComplex([System.Numerics.BigInteger]$ar,[System.Numerics.BigInteger]$bi) {
		$this.Init($ar,$bi)
    }

	# BigNum : (BigInteger) Standard Constructor for a pure real number using a BigInteger.
	BigComplex([System.Numerics.BigInteger]$ar) {
		$this.Init($ar,0)
    }

	# BigNum : () Standard Empty Constructor, returns a null BigComplex.
	BigComplex() {
		$this.Init(0,0)
    }
	# BigNum : () Standard Empty Constructor, returns a null BigComplex.
	BigComplex([string]$val) {
		$this.extractFromString($val)
    }

	#endregion Constructors



	#region Init and Extractors

	# Init : INTERNAL USE. Initialise and clean up all internal values of a BigNum instance.
	hidden [void] Init([BigNum]$ar,[BigNum]$bi) {
		[System.Numerics.BigInteger] $newResolution = [System.Numerics.BigInteger]::Max($ar.GetMaxDecimalResolution(),$bi.GetMaxDecimalResolution())
		
		$this.realPart = $ar.CloneWithNewResolution($newResolution)
        $this.imaginaryPart = $bi.CloneWithNewResolution($newResolution)
    }

	# extractFromString : INTERNAL USE. Initialise a BigComplex instance using a String as a source.
	hidden [void] extractFromString([string]$stringVal) {
		$numberFormat = (Get-Culture).NumberFormat
		$negChar = $numberFormat.negativeSign
		$tmpiChar = [BigComplex]::iChar

		$tmpRealPart = ([BigNum]0)
		$tmpImaginaryPart = ([BigNum]0)

		$mustFlipR = $false
		$mustFlipI = $false

		$cleanStringVal = $stringVal -replace $negChar,'-'
		$cleanStringVal = $cleanStringVal -replace $tmpiChar,'i'

		$tmpString = $cleanStringVal -replace '\+',''
		$nbPlus = $cleanStringVal.Length - $tmpString.Length
		$tmpString = $cleanStringVal -replace '-',''
		$nbMinus = $cleanStringVal.Length - $tmpString.Length
		$tmpString = $cleanStringVal -replace 'i',''
		$nbI = $cleanStringVal.Length - $tmpString.Length

		If(($nbPlus -gt 2) -or ($nbMinus -gt 2) -or (($nbPlus+$nbMinus) -gt 2) -or ($nbI -gt 1)) {
			throw "Malformed complex number"
		}

		if($nbI -eq 0) {
			# If we have no i-part -> only real
			$tmpRealPart = ([BigNum]$cleanStringVal)
		} elseif (($nbPlus+$nbMinus) -eq 0) {
			# If we have an i-part but no symbols -> only positive imaginary
			$tmpImaginaryPart = ([BigNum]$cleanStringVal)
			if(($tmpImaginaryPart.IsNull()) -and ($cleanStringVal -eq "i")) { $tmpImaginaryPart = ([BigNum]1) }
		} elseif (($nbPlus+$nbMinus) -eq 1) {
			# If we only have one symbole
			# Before the symbol -> Positive real part (might be empty)
			# After the symbol -> imaginary part, sign of the symbol (non-empty)
			if ($nbPlus -eq 1) {
				$tmpSplit = $cleanStringVal.Split('+')
			} else {
				$tmpSplit = $cleanStringVal.Split('-')
				$mustFlipI = $true
			}
			$tmpRealPart = ([BigNum]$tmpSplit[0])
			$tmpImaginaryPart = ([BigNum]$tmpSplit[1])
			if(($tmpImaginaryPart.IsNull()) -and ($tmpSplit[1] -eq "i")) { $tmpImaginaryPart = ([BigNum]1) }

		} else {
			# If we have two symbole
			# Before the second symbol -> real part, sign of the first symbol
			# After the second symbol -> imaginary part, sign of the second symbol
			$cursor = -1
			$symbolCounter = 0
			while ($symbolCounter -lt 2) {
				$cursor += 1
				if(($cleanStringVal[$cursor] -eq '+') -or ($cleanStringVal[$cursor] -eq '-')){ $symbolCounter += 1 }
			}
			$tmpRealPart = ([BigNum]($cleanStringVal.Substring(0,$cursor)))
			$tmpImaginaryPart = ([BigNum]($cleanStringVal.Substring($cursor)))
		}

		if ($mustFlipR) { $tmpRealPart *= -1 }
		if ($mustFlipI) { $tmpImaginaryPart *= -1 }
		$this.Init($tmpRealPart,$tmpImaginaryPart)
	}

	#endregion Init and Extractors

	
	
	#region direct Accessors and evaluation tools

	# GetMaxDecimalResolution : returns the maximum allowed decimal expansion of the BigComplex.
	[System.Numerics.BigInteger]GetMaxDecimalResolution(){

		return [System.Numerics.BigInteger]::Min($this.realPart.GetMaxDecimalResolution(),$this.imaginaryPart.GetMaxDecimalResolution())
	}

	# getDecimalExpantionLength : returns the current decimal expansion of the BigNum.
	[System.Numerics.BigInteger]getDecimalExpantionLength(){
		return [System.Numerics.BigInteger]::Max($this.realPart.getDecimalExpantionLength(),$this.imaginaryPart.getDecimalExpantionLength())
	}

	# IsStrictlyNegative : returns $true only if the number is strictly negative.
	[bool] IsStrictlyNegative(){
		return ($this.realPart.IsStrictlyNegative() -and ($this.imaginaryPart.IsStrictlyNegative() -or $this.imaginaryPart.IsNull()))
	}

	# IsNegative : returns $true if the number is negative or null.
	[bool] IsNegative(){
		return ($this.realPart.IsNegative() -and ($this.imaginaryPart.IsNegative() -or $this.imaginaryPart.IsNull()))
	}

	# IsStrictlyPositive : returns $true only if the number is strictly positive.
	[bool] IsStrictlyPositive(){
		return ($this.realPart.IsStrictlyPositive() -and ($this.imaginaryPart.IsStrictlyPositive() -or $this.imaginaryPart.IsNull()))
	}

	# IsPositive : returns $true if the number is positive or null.
	[bool] IsPositive(){
		return ($this.realPart.IsPositive() -and ($this.imaginaryPart.IsPositive() -or $this.imaginaryPart.IsNull()))
	}

	# IsNull : returns $true if the number is null.
	[bool] IsNull(){
		return ($this.realPart.IsNull() -and $this.imaginaryPart.IsNull())
	}

	# IsNotNull : returns $true if the number is not null.
	[bool] IsNotNull(){
		return ($this.realPart.IsNotNull() -or $this.imaginaryPart.IsNotNull())
	}

	# IsReal : returns $true if the number has no imaginary Part.
	[bool] IsPureReal(){
		return ($this.imaginaryPart.IsNull())
	}

	# IsReal : returns $true if the number has no real Part.
	[bool] IsPureImaginary(){
		return ($this.realPart.IsNull())
	}

	# IsInteger : returns $true if the number has no decimal expansion.
	[bool] IsInteger() {
		return ($this.realPart.IsInteger() -and $this.imaginaryPart.IsInteger())
	}

	# HasDecimals : returns $true if the number has any decimal expansion.
	[bool] HasDecimals() {
		return ($this.realPart.HasDecimals() -or $this.imaginaryPart.HasDecimals())
	}

	#endregion direct Accessors and evaluation tools
	
	
	
	#region Cloning and Resolution Tools

	# Clone : returns a new instance of BigNum.
	[BigComplex] Clone() {
		return [BigComplex]::new($this.realPart,$this.imaginaryPart)
	}

	# CloneFromObject : (object) Create and return a BigComplex object using any approriate Constructor.
	static [BigComplex] CloneFromObject([object] $val) {
		return [BigComplex]::new($val)
	}

	# CloneWithNewResolution : returns a new instance of BigNum with the maximum resolution altered, Trucate if needed.
	[BigComplex] CloneWithNewResolution([System.Numerics.BigInteger] $newResolution) {
		$tmpAR = $this.realPart.CloneWithNewResolution($newResolution)
		$tmpBI = $this.imaginaryPart.CloneWithNewResolution($newResolution)
		return [BigComplex]::new($tmpAR,$tmpBI)
	}

	# CloneWithStandardResolution : returns a new instance of BigNum with the maximum resolution set to the default one.
	[BigComplex] CloneWithStandardResolution() {
		$tmpAR = $this.realPart.CloneWithStandardResolution()
		$tmpBI = $this.imaginaryPart.CloneWithStandardResolution()
		return [BigComplex]::new($tmpAR,$tmpBI)
	}

	# CloneWithAdjustedResolution : returns a new instance of BigNum with the maximum resolution set to the current length of the decimal expansion.
	[BigComplex] CloneWithAdjustedResolution(){
		$newResolution = [System.Numerics.BigInteger]::Max($this.realPart.getDecimalExpantionLength(),$this.imaginaryPart.getDecimalExpantionLength())
		$tmpAR = $this.realPart.CloneWithNewResolution($newResolution)
		$tmpBI = $this.imaginaryPart.CloneWithNewResolution($newResolution)
		return [BigComplex]::new($tmpAR,$tmpBI)
	}

	# CloneWithAddedResolution : returns a new instance of BigNum with the maximum resolution set to the current length of the decimal expansion.
	[BigComplex] CloneWithAddedResolution([System.Numerics.BigInteger]$val){
		#this add $val to the max resolution of the number
		if($val -lt 0) {
			throw "Error in [BigComplex]::CloneWithAddedResolution : ${val} must be positive"
		}

		$newResolution = [System.Numerics.BigInteger]::Max($this.realPart.getDecimalExpantionLength(),$this.imaginaryPart.getDecimalExpantionLength())
		$tmpAR = $this.realPart.CloneWithNewResolution($newResolution + $val)
		$tmpBI = $this.imaginaryPart.CloneWithNewResolution($newResolution + $val)
		return [BigComplex]::new($tmpAR,$tmpBI)
	}

	# CloneAndReducePrecisionBy : returns a new instance of BigNum with the maximum resolution reduiced by $length and the number rounded if needed.
	[BigComplex] CloneAndReducePrecisionBy([System.Numerics.BigInteger]$length){
		#this shorten the resolution by $val amount, and rounds if necessary
		if($length -lt 0) {
			throw "Error in [BigComplex]::CloneAndReducePrecisionBy : length must be positive or null"
		}
		
		$newResolution = [System.Numerics.BigInteger]::Max($this.realPart.GetMaxDecimalResolution(),$this.imaginaryPart.GetMaxDecimalResolution())
		
		$newLength = $newResolution - $length

		$tmpAR = $this.realPart.Round($newLength)
		$tmpBI = $this.imaginaryPart.Round($newLength)

		return [BigComplex]::new($tmpAR,$tmpBI)
	}

	#endregion Cloning and Resolution Tools



	#region Standard Interface Implementations

	# CompareTo : IComparable Implementation. Compares values in magnitude signed with the real part.
	[int] CompareTo([object] $other) {
		# Simply perform (case-insensitive) lexical comparison on the .Kind
		# property values.
		if ($null -eq $other) {return 1}

		if ($other.GetType() -eq $this.GetType()) {
			[BigComplex] $tmpOther = $other.Clone()
		} else {
			[BigComplex] $tmpOther = [BigComplex]::CloneFromObject($other)
		}

		# if (($this.realPart -eq $tmpOther.realPart) -and ($this.imaginaryPart -eq $tmpOther.imaginaryPart)) { return 0 }

		if (($this.MagnitudeSquared()*(($this.realPart.IsStrictlyNegative()?-1:1))) -eq ($tmpOther.MagnitudeSquared()*(($tmpOther.realPart.IsStrictlyNegative()?-1:1)))) {return 0 } # -eq

		if (($this.MagnitudeSquared()*(($this.realPart.IsStrictlyNegative()?-1:1))) -lt ($tmpOther.MagnitudeSquared()*(($tmpOther.realPart.IsStrictlyNegative()?-1:1)))) {return -1 } # -lt

		return 1 # -gt
    }

	# Equals : IEquatable Implementation. Allows for the use of -eq, and -ne operators.
	[bool] Equals([object] $other) {
		$isEqual = $true
		
		if ($other.GetType() -eq $this.GetType()) {
			[BigComplex] $tmpOther = $other.Clone()
		} else {
			[BigComplex] $tmpOther = [BigComplex]::CloneFromObject($other)
		}

		if($this.realPart -ne $tmpOther.realPart){
			$isEqual = $false
		}
		if($this.imaginaryPart -ne $tmpOther.imaginaryPart){
			$isEqual = $false
		}

		return $isEqual
    }

	# GetHashCode : IComparable Implementation. -1 if this -lt other. 0 if this -eq other. 1 if this -gt other or if other is null.
	[int] GetHashCode() {
		return $this.ToString().GetHashCode()
    }

	# op_Equality : Standard overload for the -eq operator. Not sure it ever gets called.
	static [bool] op_Equality([BigNum] $a, [BigNum] $b) {
		return ($a.Equals($b))
	}

	# op_Inequality : Standard overload for the -ne operator. Not sure it ever gets called.
	static [bool] op_Inequality([BigNum] $a, [BigNum] $b) {
		return (-not $a.Equals($b))
	}

	
	# ToString : IFormattable Implementation. Return a culture-aware default string representation of the original BigComplex.
	[string] ToString()
	{
		$currCulture = (Get-Culture)
		return $this.ToString("G", $currCulture);
	}
	
	# ToString : IFormattable Implementation. Return a culture-aware format-specific string representation of the original BigComplex.
	[string] ToString([string] $format)
	{
		$currCulture = (Get-Culture)
		return $this.ToString($format, $currCulture);
	}

	# ToString : IFormattable Implementation. Return a culture-specific default string representation of the original BigComplex.
	[string] ToString([IFormatProvider] $provider)
	{
		return $this.ToString("G", $provider);
	}

	# ToString : IFormattable Implementation. Return a culture-aware string representation of the original BigComplex.
	[string] ToString([string] $format, [IFormatProvider] $provider) {
		if ($format -ne '') { $newFormat = $format }else { $newFormat = "G" }
		if ($null -ne $provider) { $newProvider = $provider }else { $newProvider = (Get-Culture) }
		$tmpiChar = [BigComplex]::iChar


		$strBuilder = ''

		if ($this.realPart.IsNotNull()) {
			$strBuilder += $this.realPart.ToString($newFormat, $newProvider)
			if($this.imaginaryPart.IsStrictlyPositive()) {
				$strBuilder += '+'
			}
		}

		if ($this.imaginaryPart.IsNotNull()) {
			if (($this.imaginaryPart -ne 1) -and ($this.imaginaryPart -ne -1)) {
				$strBuilder += $this.imaginaryPart.ToString($newFormat, $newProvider)
			}
			if ($this.imaginaryPart -eq -1) {
				$strBuilder += '-'
			}
			# $strBuilder += 'i'
			$strBuilder += $tmpiChar
		}

		if($this.realPart.IsNull() -and $this.imaginaryPart.IsNull()){
			$strBuilder += '0'
		}

		return $strBuilder
	}

	#endregion Standard Interface Implementations



	#region Base Operators

	# op_Addition : Standard overload for the "+" operator.
	static [BigComplex] op_Addition([BigComplex] $a, [BigComplex] $b) {
		[BigNum]$resultReal = $a.realPart + $b.realPart
		[BigNum]$resultImag = $a.imaginaryPart + $b.imaginaryPart

		return [BigComplex]::new($resultReal, $resultImag)
	}

	# op_Subtraction : Standard overload for the "-" operator.
	static [BigComplex] op_Subtraction([BigComplex] $a, [BigComplex] $b) {
		[BigNum]$resultReal = $a.realPart - $b.realPart
		[BigNum]$resultImag = $a.imaginaryPart - $b.imaginaryPart

		return [BigComplex]::new($resultReal, $resultImag)
	}

	# op_Multiply : Standard overload for the "*" operator.
	static [BigComplex] op_Multiply([BigComplex] $a, [BigComplex] $b) {
		[BigNum]$resultReal = ($a.realPart * $b.realPart) - ($a.imaginaryPart * $b.imaginaryPart)
		[BigNum]$resultImag = ($a.realPart * $b.imaginaryPart) + ($a.imaginaryPart * $b.realPart)

		return [BigComplex]::new($resultReal, $resultImag)
	}

	# op_Division : Standard overload for the "/" operator.
	static [BigComplex] op_Division([BigComplex] $a, [BigComplex] $b) {
		if ($b.IsNull()) {
			throw "Error in [BigNum]::op_Division : Divisor operand must not be null"
		}

		[BigNum]$resultReal = (($a.realPart * $b.realPart) + ($a.imaginaryPart * $b.imaginaryPart)) / (($b.realPart * $b.realPart) + ($b.imaginaryPart * $b.imaginaryPart))
		[BigNum]$resultImag = (($a.imaginaryPart * $b.realPart) - ($a.realPart * $b.imaginaryPart)) / (($b.realPart * $b.realPart) + ($b.imaginaryPart * $b.imaginaryPart))

		return [BigComplex]::new($resultReal, $resultImag)
	}

	# op_Modulus : Standard overload for the "%" operator.
	static [BigComplex] op_Modulus([BigComplex] $a, [BigComplex] $b) {
		[System.Numerics.BigInteger]$newResolution = [System.Numerics.BigInteger]::Max($a.GetMaxDecimalResolution(),$b.GetMaxDecimalResolution())

		if($a.IsPureReal() -and $b.IsPureReal()) {
			return ([BigComplex]($a.realPart % $b.realPart))
		}

		[BigComplex]$tmpA = $a.CloneWithNewResolution($newResolution)
		[BigComplex]$tmpB = $b.CloneWithNewResolution($newResolution)

		[BigComplex]$quotient = $tmpA/$tmpB
		[BigComplex]$nearestInt = $quotient.Round(0)

		[BigComplex]$tmpResult = $tmpA - ($tmpB * $nearestInt)

		return $tmpResult.CloneWithNewResolution($newResolution)
	}

	# # op_LeftShift : Standard overload for the "<<" operator.
	# static [BigNum] op_LeftShift([BigNum] $a, [System.Numerics.BigInteger] $b) {
	# 	[System.Numerics.BigInteger]$tmpA = $a.integerVal
	# 	[System.Numerics.BigInteger]$newShiftVal = $a.shiftVal - $b

	# 	if ($newShiftVal -lt 0) {
	# 		$tmpA *= [BigNum]::PowTenPositive(-$newShiftVal)
	# 		$newShiftVal=0
	# 	}

	# 	return [BigNum]::new($tmpA,$newShiftVal,$a.negativeFlag,$a.GetMaxDecimalResolution())
	# }

	# # op_LeftShift : Standard overload for the ">>" operator.
	# static [BigNum] op_RightShift([BigNum] $a, [System.Numerics.BigInteger] $b) {
	# 	[System.Numerics.BigInteger]$tmpA = $a.integerVal
	# 	[System.Numerics.BigInteger]$newShiftVal = $a.shiftVal + $b

	# 	return [BigNum]::new($tmpA,$newShiftVal,$a.negativeFlag,$a.GetMaxDecimalResolution())
	# }

	# -bxor   op_ExclusiveOr
	# -band   op_BitwiseAnd
	# -bor    op_BitwiseOr
	# -bnot   op_OnesComplement

	#endregion Base Operators



	#region internals private methods


	#endregion internals private methods



	#region static Operators and Methods

	# MagnitudeMin : return a clone of the object with the smalest magnitude 
	static [BigComplex] MagnitudeMin([BigComplex] $a,[BigComplex] $b) {
		if ($a.MagnitudeSquared() -lt $b.MagnitudeSquared()) {
			return $a.Clone()
		}
		return $b.Clone()
	}

	# MagnitudeMax : return a clone of the object with the biggest magnitude 
	static [BigComplex] MagnitudeMax([BigComplex] $a,[BigComplex] $b) {
		if ($a.MagnitudeSquared() -gt $b.MagnitudeSquared()) {
			return $a.Clone()
		}
		return $b.Clone()
	}

	# AngleMin : return a clone of the object with the smalest angle
	static [BigComplex] AngleMin([BigComplex] $a,[BigComplex] $b) {
		if ($a.Arg() -lt $b.Arg()) {
			return $a.Clone()
		}
		return $b.Clone()
	}

	# AngleMax : return a clone of the object with the biggest angle
	static [BigComplex] AngleMax([BigComplex] $a,[BigComplex] $b) {
		if ($a.Arg() -gt $b.Arg()) {
			return $a.Clone()
		}
		return $b.Clone()
	}

	# AbsAngleMin : return a clone of the object with the smalest angle
	static [BigComplex] AbsAngleMin([BigComplex] $a,[BigComplex] $b) {
		if ($a.PosArg() -lt $b.PosArg()) {
			return $a.Clone()
		}
		return $b.Clone()
	}

	# AbsAngleMax : return a clone of the object with the biggest angle
	static [BigComplex] AbsAngleMax([BigComplex] $a,[BigComplex] $b) {
		if ($a.PosArg() -gt $b.PosArg()) {
			return $a.Clone()
		}
		return $b.Clone()
	}


	# Ln : Returns the Natural Logarithm (Logarithme Neperien) in base e for $value.
	static [BigComplex] Ln([BigComplex] $value) {
		if ($value.IsNull()) {
			throw "[BigComplex]::Ln() error: logarithm is not defined for value = 0"
		}

		[BigNum] $tmpMagnitude = $value.CloneWithNewResolution($value.GetMaxDecimalResolution()*2).Magnitude()
		[BigNum] $tmpArg = $value.CloneWithNewResolution($value.GetMaxDecimalResolution()*2).Arg()

		[BigNum] $tmpRealPart = [BigNum]::Ln($tmpMagnitude)
		[BigNum] $tmpImaginaryPart = $tmpArg

		return [BigComplex]::new($tmpRealPart, $tmpImaginaryPart).CloneWithNewResolution($value.GetMaxDecimalResolution())
	}

	# Exp : Returns the value of e to the power $exponent.
	static [BigComplex] Exp([BigComplex] $exponent) {
		[BigNum] $resultReal = [BigNum]::Exp($exponent.realPart) * [BigNum]::Cos($exponent.imaginaryPart)
		[BigNum] $resultImag = [BigNum]::Exp($exponent.realPart) * [BigNum]::Sin($exponent.imaginaryPart)

		return [BigComplex]::new($resultReal, $resultImag)
	}

	# Log : Returns the Logarithm in base $base for $value.
	static [BigComplex] Log([BigComplex] $base, [BigComplex] $value) {
		if ($base.IsNull()) {
			throw "[BigComplex]::Log() error: logarithm is not defined for base = 0"
		}

		if ($value.IsNull()) {
			throw "[BigComplex]::Log() error: logarithm is not defined for value = 0"
		}

		[BigComplex] $lnValue = [BigComplex]::Ln($value.CloneWithNewResolution($value.GetMaxDecimalResolution()*2))
		[BigComplex] $lnBase = [BigComplex]::Ln($base.CloneWithNewResolution($value.GetMaxDecimalResolution()*2))

		return ($lnValue / $lnBase).CloneWithNewResolution($value.GetMaxDecimalResolution())
	}


	# Pow : Returns the value of $value to the power $exponent. Dispaches to BigNum Pow as needed.
	static [BigComplex] Pow([BigComplex] $base, [BigComplex] $exponent) {
		if($base.IsNull()){
			return ([BigComplex]0).CloneWithNewResolution([System.Numerics.BigInteger]::Max($base.GetMaxDecimalResolution(),$exponent.GetMaxDecimalResolution()))
		}

		if($base.IsPureReal() -and $base.IsStrictlyPositive() -and $exponent.IsPureReal()){
			return ([BigComplex]([BigNum]::Pow($base.realPart,$exponent.realPart)))
		}

		if($base.IsPureReal() -and $base.IsPositive() -and $exponent.IsPureReal()){
			return ([BigComplex]([BigNum]::Pow($base.realPart,$exponent.realPart)))
		}

		return [BigComplex]::PowComplex($base, $exponent)
	}

	# PowComplex : INTERNAL USE. Returns the value of $base to the power $exponent.
	hidden static [BigComplex] PowComplex([BigComplex] $base, [BigComplex] $exponent) {
		[System.Numerics.BigInteger] $targetRes = [System.Numerics.BigInteger]::Max($base.GetMaxDecimalResolution(),$exponent.GetMaxDecimalResolution())
		[System.Numerics.BigInteger] $wrkRes = $targetRes*2
		

		if ($base.IsNull()) {
			if ($exponent.IsNull()) {
				throw "0^0 is undefined"
			} elseif ($exponent.IsPureReal() -and $exponent.IsStrictlyPositive()) {
				return ([BigComplex]0).CloneWithNewResolution($targetRes)
			} else {
				throw "Error in [BigComplex]::PowComplex : 0^x is undefined for complex or negative exponents"
			}
		}

		[BigComplex] $tmpBase = $base.CloneWithNewResolution($wrkRes)
		[BigComplex] $tmpExponent = $exponent.CloneWithNewResolution($wrkRes)

		[BigComplex] $logBase = [BigComplex]::Ln($tmpBase)
		[BigComplex] $exponentTimesLog = $tmpExponent * $logBase
		[BigComplex] $result = [BigComplex]::Exp($exponentTimesLog)
		return $result.CloneWithNewResolution($targetRes)
	}

	# Sqrt : Returns the value of the Square Root of $value.
	static [BigComplex] Sqrt([BigComplex] $value) {
		if ($value.IsPureReal() -and $value.IsPositive()) {
        	return [BigNum]::Sqrt($value.realPart)
		}

		[System.Numerics.BigInteger] $targetRes = $value.GetMaxDecimalResolution()
		[System.Numerics.BigInteger] $wrkRes = $targetRes*2

		if ($value -eq "-1") {
        	return ([BigComplex]"i").CloneWithNewResolution($targetRes)
		}

		$tmpValue = $value.CloneWithNewResolution($wrkRes)

		[BigNum] $tmpMagnitude = $tmpValue.Magnitude()
		[BigNum] $tmpTheta = $tmpValue.Arg()

		[BigNum] $sqrtMagnitude = [BigNum]::Sqrt($tmpMagnitude)
		[BigNum] $halfTheta = $tmpTheta / ([BigNum]2)

		[BigNum] $real = $sqrtMagnitude * [BigNum]::Cos($halfTheta)
		[BigNum] $imag = $sqrtMagnitude * [BigNum]::Sin($halfTheta)

		[BigComplex] $result = [BigComplex]::new($real, $imag)

		return $result.CloneWithNewResolution($targetRes)
	}

	# Cbrt : Returns the value of the Cubic Root of $value using the Newton-Raphson algorithm.
	static [BigComplex] Cbrt([BigComplex] $value) {
		return [BigComplex]::NthRootInt(3,$value)
	}

	# NthRoot : Returns the value of the Nth ($n) Root of $value. Calls NthRootInt if faster.
	static [BigComplex] NthRoot([BigComplex] $n, [BigComplex] $value) {
		if ($n -eq 0) {
			throw "[BigNum]::NthRoot() - n cannot be zero"
		}

		if($n.IsPureReal() -and $value.IsPureReal() -and $n.IsStrictlyPositive() -and ((($n.realPart)%2)-eq 1)) {
			return [BigNum]::NthRoot($n.realPart,$value.realPart)
		}

		if($n.IsPureReal() -and $n.realPart.IsInteger()) {
			return [BigComplex]::NthRootInt($n.realPart.Int(),$value)
		}

		[System.Numerics.BigInteger] $targetRes = [System.Numerics.BigInteger]::Max($n.GetMaxDecimalResolution(),$value.GetMaxDecimalResolution())
		[System.Numerics.BigInteger] $wrkRes = $targetRes*2

		$tmpValue = $value.CloneWithNewResolution($wrkRes)
		$tmpN = $n.CloneWithNewResolution($wrkRes)

		$logValue = [BigComplex]::Ln($tmpValue)
		$invN = (([BigComplex]1).CloneWithNewResolution($wrkRes)) / $tmpN
		[BigComplex] $result = [BigComplex]::Exp($logValue * $invN)

		return $result.CloneWithNewResolution($targetRes)
	}

	# NthRootInt : INTERNAL USE. Returns the value of the Nth ($n, being an integer) Root of $value.
	hidden static [BigComplex] NthRootInt([System.Numerics.BigInteger] $n, [BigComplex] $value) {
		if ($n -eq 0) {
			throw "[BigNum]::NthRootInt() - n cannot be zero"
		}

		[System.Numerics.BigInteger] $targetRes = $value.GetMaxDecimalResolution()
		[System.Numerics.BigInteger] $wrkRes = $targetRes*2

		$tmpValue = $value.CloneWithNewResolution($wrkRes)

		if ($n -lt 0) {
			# For negative roots: return reciprocal of positive root
			$posRoot = [BigComplex]::NthRootInt(-$n, $tmpValue)
			return (([BigComplex]1) / $posRoot).CloneWithNewResolution($targetRes)
		}

		# Convert z to polar form: z = r * e^(iθ)
		[BigNum] $tmpMagnitude = $tmpValue.Magnitude()
		[BigNum] $tmpArg = $tmpValue.Arg()

		# Compute root of magnitude and divide argument by n
		[BigNum] $rootMagnitude = [BigNum]::NthRootInt($n, $tmpMagnitude)
		[BigNum] $angle = $tmpArg / ([BigNum]::new($n).CloneWithNewResolution($wrkRes))

		# Reconstruct root using Euler's formula: r^(1/n) * (cos(θ/n) + i·sin(θ/n))
		[BigNum] $tmpRealPart = $rootMagnitude * [BigNum]::Cos($angle)
		[BigNum] $tmpImagPart = $rootMagnitude * [BigNum]::Sin($angle)

		return [BigComplex]::new($tmpRealPart, $tmpImagPart).CloneWithNewResolution($targetRes)
	}

	# ModPow : Returns the modular exponentiation of $base raisend to the power $exponent modulo $modulus. Calls ModPowPosInt if possible.
	static [BigComplex] ModPow([BigComplex] $base, [BigComplex] $exponent, [BigComplex] $modulus) {
		if ($base.IsPureReal() -and $exponent.IsPureReal() -and $modulus.IsPureReal()) {
			return ([BigComplex]::new([BigNum]::ModPow($base.realPart.clone(),$exponent.realPart.clone(),$modulus.realPart.clone())))
		}

		return ([BigComplex]::Pow($base,$exponent) % $modulus).Clone()
	}

	# Factorial : Returns $value Factorial. Internaly calls FactorialIntMulRange.
	static [BigComplex] Factorial([BigComplex] $z) {
		if ($z.IsPureReal()) {
			return [BigNum]::Gamma($z.realPart.Clone())
		}

		[BigComplex]$tmpZ = $z + 1

		return [BigComplex]::Gamma($tmpZ).CloneWithNewResolution($z.GetMaxDecimalResolution())
	}

	# Gamma : Compute the value of the Gamma function for z.
	static [BigComplex] Gamma([BigComplex] $z){
		# integers ≤ 0  →  poles
		if ($z.IsPureReal() -and $z.IsInteger() -and $z.IsNegative()) {
			throw "[BigComplex]::Gamma(): pole at negative or null real integer z"
		}

		if ($z.IsPureReal()) {
			return [BigNum]::Gamma($z.realPart.Clone())
		}

		[System.Numerics.BigInteger] $targetRes = $z.GetMaxDecimalResolution()
		[System.Numerics.BigInteger] $wrkRes = $targetRes+10

		$tmpValue = $z.CloneWithNewResolution($wrkRes)

		[BigComplex] $result = [BigComplex]::GammaComplex($tmpValue)

		return $result.CloneWithNewResolution($targetRes)
	}

	# GammaComplex : INTERNAL USE. Compute the complex value of the Gamma function for complex z.
	hidden static [BigComplex] GammaComplex( [BigComplex] $z ){

		if ($z.IsPureReal() -and $z.IsInteger() -and $z.IsNegative()) {
			throw "[BigComplex]::GammaComplex(): pole at negative or null real integer z"
		}
		
		[System.Numerics.BigInteger] $targetRes = $z.GetMaxDecimalResolution()
		[BigNum] $targetResBN = [BigNum]::new($targetRes)
		[System.Numerics.BigInteger] $wrkRes = ($targetResBN*1.1).Ceiling(0).Int()+10

		$tmpValue = $z.CloneWithNewResolution($wrkRes)

		$lnG = [BigComplex]::LnGammaComplex($tmpValue.CloneWithNewResolution($wrkRes))
		$G   = [BigComplex]::Exp($lnG)
		return $G.Truncate($wrkRes)
	}

	# LnGammaComplex : INTERNAL USE. Compute the Log base e of the complex Gamma function.
	hidden static [BigComplex] LnGammaComplex([BigComplex] $z ){
		# if ($z.realPart -le 0) {
		# 	throw "[BigNum]::LnGammaComplex(): z must be > 0  (use Gamma to get reflection)."
		# }

		[System.Numerics.BigInteger] $wrkRes = $z.GetMaxDecimalResolution() + 10
		[System.Numerics.BigInteger] $targetResolution = $z.GetMaxDecimalResolution()
		[BigComplex] $tmpZ = $z.CloneWithNewResolution($wrkRes)

		# Pick Spouge parameter a
        [System.Numerics.BigInteger] $selectedA = [BigNum]::SpouseChooseA($wrkRes)

		# Series S = c₀ + Σ_{k=1}^{a-1} c_k / (x-1+k)
        [BigComplex] $S = [BigNum]::SpougeCoefficient(0,$selectedA,$wrkRes)
        for ([System.Numerics.BigInteger] $k = 1; $k -lt $selectedA; $k += 1) {
            [BigComplex] $ck = [BigNum]::SpougeCoefficient($k,$selectedA,$wrkRes)
            [BigComplex] $den = $tmpZ - 1 + $k
            $S += ($ck / $den)
        }

		# Main terms
        $term1 = ($tmpZ - 0.5) * [BigComplex]::Ln(($tmpZ + $selectedA - 1).CloneWithNewResolution($wrkRes))
        $term2 = (-($tmpZ + $selectedA - 1)).CloneWithNewResolution($wrkRes)
        $term3 = [BigComplex]::Ln($S.CloneWithNewResolution($wrkRes))

		$LnGammaResult = ($term1 + $term2 + $term3)

		return $LnGammaResult.Truncate($targetResolution)
	}

	#endregion static Operators and Methods

	

	#region static Trigonometry Methods

	# Sin: Sine Function.
	static [BigComplex] Sin([BigComplex] $val) {
		
		# Sin is defined on C

		[System.Numerics.BigInteger] $targetRes = $val.GetMaxDecimalResolution()
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		if($val.IsPureReal()) {
			return ([BigComplex]::new([BigNum]::Sin($val.realPart.Clone())))
		}

		[BigComplex] $tmpVal = $val.CloneWithNewResolution($wrkRes)

		[BigComplex] $i = ([BigComplex]"i").CloneWithNewResolution($wrkRes)
		[BigComplex] $twoI = ([BigComplex]"2i").CloneWithNewResolution($wrkRes)
		[BigComplex] $expIz = [BigComplex]::Exp($i * $tmpVal)
		[BigComplex] $expNegIz = [BigComplex]::Exp(-$i * $tmpVal)

		[BigComplex] $result = ($expIz - $expNegIz) / $twoI

		# [BigComplex] $result = (([BigComplex]::Exp(([BigComplex]"i").CloneWithNewResolution($wrkRes)*$tmpVal)) - ([BigComplex]::Exp(([BigComplex]"-i").CloneWithNewResolution($wrkRes)*$tmpVal))) /([BigComplex]"2i").CloneWithNewResolution($wrkRes)

		return $result.CloneWithNewResolution($targetRes)
	}

	# Cos: Cosine Function.
	static [BigComplex] Cos([BigComplex] $val) {
		
		# Cos is defined on C

		[System.Numerics.BigInteger] $targetRes = $val.GetMaxDecimalResolution()
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		if($val.IsPureReal()) {
			return ([BigComplex]::new([BigNum]::Cos($val.realPart.Clone())))
		}

		[BigComplex] $tmpVal = $val.CloneWithNewResolution($wrkRes)

		[BigComplex] $i = ([BigComplex]"i").CloneWithNewResolution($wrkRes)
		[BigComplex] $two = ([BigComplex]"2").CloneWithNewResolution($wrkRes)
		[BigComplex] $expIz = [BigComplex]::Exp($i * $tmpVal)
		[BigComplex] $expNegIz = [BigComplex]::Exp(-$i * $tmpVal)

		[BigComplex] $result = ($expIz + $expNegIz) / $two

		return $result.CloneWithNewResolution($targetRes)
	}

	# Tan: Tangent Function.
	static [BigComplex] Tan([BigComplex] $val) {

		# Tan is defined on C \ {Pi/2 + kPi, k in Z} (Cos != 0)

		[System.Numerics.BigInteger] $targetRes = $val.GetMaxDecimalResolution()
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		if($val.IsPureReal()) {
			return ([BigComplex]::new([BigNum]::Tan($val.realPart.Clone())))
		}

		[BigComplex] $tmpVal = $val.CloneWithNewResolution($wrkRes)

		[BigComplex] $sinZ = [BigComplex]::Sin($tmpVal)
		[BigComplex] $cosZ = [BigComplex]::Cos($tmpVal)

		# if (cosX.Abs() -lt [BigNum]::PowTen(-x.maxDecimalResolution + 2)) {
		# 	throw "Tan(x) undefined: Cos(x) too close to zero."
		# }

		if($cosZ.IsNull()) {
			throw "Tan(z) undefined: Cos(z) is null."
		}

		[BigComplex] $result = $sinZ / $cosZ

		return $result.CloneWithNewResolution($targetRes)
	}

	# Csc: Cosecant Function.
	static [BigComplex] Csc([BigComplex] $val) {

		# Csc is defined on C \ {kPi, k in Z} (Sin != 0)

		[System.Numerics.BigInteger] $targetRes = $val.GetMaxDecimalResolution()
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		if($val.IsPureReal()) {
			return ([BigComplex]::new([BigNum]::Csc($val.realPart.Clone())))
		}

		[BigComplex] $tmpVal = $val.CloneWithNewResolution($wrkRes)

		[BigComplex] $constOne = ([BigComplex]1).CloneWithNewResolution($wrkRes)
		[BigComplex] $sinZ = [BigComplex]::Sin($tmpVal)

		if($sinZ.IsNull()) {
			throw "Csc(z) undefined: Sin(z) is null."
		}

		[BigComplex] $result = $constOne / $sinZ

		return $result.CloneWithNewResolution($targetRes)
	}

	# Sec: Secant Function.
	static [BigComplex] Sec([BigComplex] $val) {

		# Sec is defined on C \ {Pi/2 + kPi, k in Z} (Cos != 0)

		[System.Numerics.BigInteger] $targetRes = $val.GetMaxDecimalResolution()
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		if($val.IsPureReal()) {
			return ([BigComplex]::new([BigNum]::Sec($val.realPart.Clone())))
		}

		[BigComplex] $tmpVal = $val.CloneWithNewResolution($wrkRes)

		[BigComplex] $constOne = ([BigComplex]1).CloneWithNewResolution($wrkRes)
		[BigComplex] $cosZ = [BigComplex]::Cos($tmpVal)

		if($cosZ.IsNull()) {
			throw "Sec(z) undefined: Cos(z) is null."
		}

		[BigComplex] $result = $constOne / $cosZ

		return $result.CloneWithNewResolution($targetRes)
	}

	# Cot: Cotangent Function.
	static [BigComplex] Cot([BigComplex] $val) {

		# Cot is defined on C \ {kPi, k in Z} (Sin != 0)

		[System.Numerics.BigInteger] $targetRes = $val.GetMaxDecimalResolution()
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		if($val.IsPureReal()) {
			return ([BigComplex]::new([BigNum]::Cot($val.realPart.Clone())))
		}

		[BigComplex] $tmpVal = $val.CloneWithNewResolution($wrkRes)

		[BigComplex] $constOne = ([BigComplex]1).CloneWithNewResolution($wrkRes)
		[BigComplex] $tanZ = [BigComplex]::Tan($tmpVal)

		if($tanZ.IsNull()) {
			throw "Cot(z) undefined: Tan(z) is null."
		}

		[BigComplex] $result = $constOne / $tanZ

		return $result.CloneWithNewResolution($targetRes)
	}

	# Arcsin: Inverse Sine Function.
	static [BigComplex] Arcsin([BigComplex] $val) {

		# Arcsin is defined on C

		[System.Numerics.BigInteger] $targetRes = $val.GetMaxDecimalResolution()
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		if($val.IsPureReal() -and ($val.realPart.Abs() -le 1)) {
				return ([BigComplex]::new([BigNum]::Arcsin($val.realPart.Clone())))
		}

		[BigComplex] $i = ([BigComplex]"i").CloneWithNewResolution($wrkRes)
    	[BigComplex] $constOne = ([BigComplex]"1").CloneWithNewResolution($wrkRes)
		[BigComplex] $tmpZ = $val.CloneWithNewResolution($wrkRes)

		[BigComplex] $sqrtTerm = [BigComplex]::Sqrt($constOne - $tmpZ * $tmpZ)
		[BigComplex] $lnArg = $i * $tmpZ + $sqrtTerm
		[BigComplex] $ln = [BigComplex]::Ln($lnArg)
		[BigComplex] $result = -$i * $ln

		return $result.CloneWithNewResolution($targetRes)
	}

	# Arccos: Inverse Cosine Function.
	static [BigComplex] Arccos([BigComplex] $val) {

		# Arccos is defined on C

		[System.Numerics.BigInteger] $targetRes = $val.GetMaxDecimalResolution()
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		if($val.IsPureReal() -and ($val.realPart.Abs() -le 1)) {
				return ([BigComplex]::new([BigNum]::Arccos($val.realPart.Clone())))
		}

		[BigComplex] $i = ([BigComplex]"i").CloneWithNewResolution($wrkRes)
    	[BigComplex] $constOne = ([BigComplex]"1").CloneWithNewResolution($wrkRes)
		[BigComplex] $tmpZ = $val.CloneWithNewResolution($wrkRes)

		[BigComplex] $sqrtTerm = [BigComplex]::Sqrt($tmpZ * $tmpZ - $constOne)
		[BigComplex] $lnArg = $tmpZ + $sqrtTerm
		[BigComplex] $ln = [BigComplex]::Ln($lnArg)
		[BigComplex] $result = -$i * $ln

		return $result.CloneWithNewResolution($targetRes)
	}

	# Arctan: Inverse Tangent Function.
	static [BigComplex] Arctan([BigComplex] $val) {

		# Arctan is defined on C

		[System.Numerics.BigInteger] $targetRes = $val.GetMaxDecimalResolution()
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		if($val.IsPureReal()) {
				return ([BigComplex]::new([BigNum]::Arctan($val.realPart.Clone())))
		}

		[BigComplex] $i = ([BigComplex]"i").CloneWithNewResolution($wrkRes)
    	[BigComplex] $constOne = ([BigComplex]"1").CloneWithNewResolution($wrkRes)
		[BigComplex] $constTwo = ([BigComplex]"2").CloneWithNewResolution($wrkRes)
		[BigComplex] $tmpZ = $val.CloneWithNewResolution($wrkRes)

		[BigComplex] $ln1 = [BigComplex]::Ln($constOne - $i * $tmpZ)
    	[BigComplex] $ln2 = [BigComplex]::Ln($constOne + $i * $tmpZ)

		[BigComplex] $result = ($i / $constTwo) * ($ln1 - $ln2)

		return $result.CloneWithNewResolution($targetRes)
	}

	# # Atan2: Two-Argument Inverse Tangent Function. Complex phase angle function.
	static [BigComplex] Atan2([BigComplex] $z1, [BigComplex] $z2) {

		# Atan2 is defined on C x C

		[System.Numerics.BigInteger] $targetRes = [System.Numerics.BigInteger]::Max($z1.GetMaxDecimalResolution(),$z2.GetMaxDecimalResolution())
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		if($z1.IsPureReal() -and $z2.IsPureReal()) {
				return ([BigComplex]::new([BigNum]::Atan2($z1.realPart.Clone(),$z2.realPart.Clone())))
		}

		[BigComplex] $i = ([BigComplex]"i").CloneWithNewResolution($wrkRes)
		[BigComplex] $minusI = ([BigComplex]"-i").CloneWithNewResolution($wrkRes)
		[BigComplex] $tmpZ1 = $z1.CloneWithNewResolution($wrkRes)
		[BigComplex] $tmpZ2 = $z2.CloneWithNewResolution($wrkRes)

		[BigComplex] $den = $tmpZ2 + ($i * $tmpZ1)
		[BigComplex] $num = [BigComplex]::Sqrt( ($tmpZ1*$tmpZ1) + ($tmpZ2*$tmpZ2) )
		[BigComplex] $result = $minusI * [BigComplex]::Ln($den / $num)

		return $result.CloneWithNewResolution($targetRes)
	}

	# Arccsc: Inverse Cosecant Function.
	static [BigComplex] Arccsc([BigComplex] $val) {

		# Arccsc is defined on C*

		[System.Numerics.BigInteger] $targetRes = $val.GetMaxDecimalResolution()
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		if($val.IsNull()) {
			throw "Arccsc(z) undefined: z is null"
		}

		# if($val.IsPureReal()) {
		# 	return ([BigComplex]::new([BigNum]::Arccsc($val.realPart.Clone())))
		# }

		[BigComplex] $tmpZ = $val.CloneWithNewResolution($wrkRes)
		[BigComplex] $constOne = ([BigComplex]"1").CloneWithNewResolution($wrkRes)

		[BigComplex] $invZ = $constOne / $tmpZ
		[BigComplex] $result = [BigComplex]::Arcsin($invZ)

		return $result.CloneWithNewResolution($targetRes)
	}

	# Arcsec: Inverse Secant Function.
	static [BigComplex] Arcsec([BigComplex] $val) {

		# Arcsec is defined on C*

		[System.Numerics.BigInteger] $targetRes = $val.GetMaxDecimalResolution()
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		if($val.IsNull()) {
			throw "Arcsec(z) undefined: z is null"
		}

		# if($val.IsPureReal()) {
		# 	return ([BigComplex]::new([BigNum]::Arcsec($val.realPart.Clone())))
		# }

		[BigComplex] $tmpZ = $val.CloneWithNewResolution($wrkRes)
		[BigComplex] $constOne = ([BigComplex]"1").CloneWithNewResolution($wrkRes)

		[BigComplex] $invZ = $constOne / $tmpZ
    	[BigComplex] $result = [BigComplex]::Arccos($invZ)

		return $result.CloneWithNewResolution($targetRes)
	}

	# Arccot: Inverse Cotangent Function.
	static [BigComplex] Arccot([BigComplex] $val) {

		# Arccot is defined on C*

		[System.Numerics.BigInteger] $targetRes = $val.GetMaxDecimalResolution()
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		if($val.IsNull()) {
			throw "Arccot(z) undefined: z is null"
		}

		# if($val.IsPureReal()) {
		# 	return ([BigComplex]::new([BigNum]::Arccot($val.realPart.Clone())))
		# }

		[BigComplex] $tmpZ = $val.CloneWithNewResolution($wrkRes)
		[BigComplex] $constOne = ([BigComplex]"1").CloneWithNewResolution($wrkRes)

		[BigComplex] $invZ = $constOne / $tmpZ
    	[BigComplex] $result = [BigComplex]::Arctan($invZ)

		return $result.CloneWithNewResolution($targetRes)
	}

	#endregion static Trigonometry Methods



	#region static Hyperbolic Trigonometry Methods

	# # Sinh: Hyperbolic Sine Function.
	# static [BigNum] Sinh([BigNum] $val) {

	# 	# Sinh is defined on R

	# 	[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
	# 	[System.Numerics.BigInteger] $wrkRes = $targetRes +5

	# 	[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)
	# 	[BigNum] $expPlus  = [BigNum]::Exp($tmpVal)
	# 	[BigNum] $expMinus = [BigNum]::Exp(-$tmpVal)
	# 	[BigNum] $half     = [BigNum]::new("0.5").CloneWithNewResolution($wrkRes)

	# 	[BigNum] $sinhVal = ($expPlus - $expMinus) * $half

	# 	return $sinhVal.Truncate($targetRes)
	# }

	# # Cosh: Hyperbolic Cosine Function.
	# static [BigNum] Cosh([BigNum] $val) {

	# 	# Cosh is defined on R

	# 	[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
	# 	[System.Numerics.BigInteger] $wrkRes = $targetRes +5

	# 	[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)
	# 	[BigNum] $expPlus  = [BigNum]::Exp($tmpVal)
	# 	[BigNum] $expMinus = [BigNum]::Exp(-$tmpVal)
	# 	[BigNum] $half     = [BigNum]::new("0.5").CloneWithNewResolution($wrkRes)

	# 	[BigNum] $coshVal = ($expPlus + $expMinus) * $half

	# 	return $coshVal.Truncate($targetRes)
	# }

	# # Tanh: Hyperbolic Tangent Function.
	# static [BigNum] Tanh([BigNum] $val) {

	# 	# Tanh is defined on R

	# 	[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
	# 	[System.Numerics.BigInteger] $wrkRes = $targetRes +5

	# 	[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)
	# 	[BigNum] $num  = [BigNum]::Sinh($tmpVal)
	# 	[BigNum] $den = [BigNum]::Cosh($tmpVal)
	# 	[BigNum] $tanhVal = ($num / $den)

	# 	return $tanhVal.Truncate($targetRes)
	# }

	# # Csch: Hyperbolic Cosecant Function.
	# static [BigNum] Csch([BigNum] $val) {

	# 	# Csch is defined on R*

	# 	if ($val.IsNull()) {
	# 		throw "Error in [BigNum]::Csch : val must not be null"
	# 	}

	# 	[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
	# 	[System.Numerics.BigInteger] $wrkRes = $targetRes +5

	# 	[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)
	# 	[BigNum] $num  = ([BigNum]1).CloneWithNewResolution($wrkRes)
	# 	[BigNum] $den = [BigNum]::Sinh($tmpVal)
	# 	[BigNum] $cschVal = ($num / $den)

	# 	return $cschVal.Truncate($targetRes)
	# }

	# # Sech: Hyperbolic Secant Function.
	# static [BigNum] Sech([BigNum] $val) {

	# 	# Sech is defined on R

	# 	[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
	# 	[System.Numerics.BigInteger] $wrkRes = $targetRes +5

	# 	[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)
	# 	[BigNum] $num  = ([BigNum]1).CloneWithNewResolution($wrkRes)
	# 	[BigNum] $den = [BigNum]::Cosh($tmpVal)
	# 	[BigNum] $sechVal = ($num / $den)

	# 	return $sechVal.Truncate($targetRes)
	# }

	# # Coth: Hyperbolic Cotangent Function.
	# static [BigNum] Coth([BigNum] $val) {

	# 	# Coth is defined on R*

	# 	if ($val.IsNull()) {
	# 		throw "Error in [BigNum]::Coth : val must not be null"
	# 	}

	# 	[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
	# 	[System.Numerics.BigInteger] $wrkRes = $targetRes +5

	# 	[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)
	# 	[BigNum] $num  = [BigNum]::Cosh($tmpVal)
	# 	[BigNum] $den = [BigNum]::Sinh($tmpVal)
	# 	[BigNum] $cothVal = ($num / $den)

	# 	return $cothVal.Truncate($targetRes)
	# }

	# # Arcsinh: Inverse Hyperbolic Sine Function.
	# static [BigNum] Arcsinh([BigNum] $val) {

	# 	# Arcsinh is defined on R

	# 	[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
	# 	[System.Numerics.BigInteger] $wrkRes = $targetRes +5

	# 	[BigNum] $constOne = ([BigNum]1).CloneWithNewResolution($wrkRes)
	# 	[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)

	# 	[BigNum] $sqrtPart  = [BigNum]::Sqrt(($tmpVal * $tmpVal) + $constOne)
	# 	[BigNum] $arcsinhVal = [BigNum]::Ln($tmpVal + $sqrtPart)

	# 	return $arcsinhVal.Truncate($targetRes)
	# }

	# # Arccosh: Inverse Hyperbolic Cosine Function.
	# static [BigNum] Arccosh([BigNum] $val) {

	# 	# Arccosh is defined on [1, +Inf[

	# 	if ($val -lt 1) {
	# 		throw "Error in [BigNum]::Arccosh : val must be equal or greater than 1"
	# 	}

	# 	[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
	# 	[System.Numerics.BigInteger] $wrkRes = $targetRes +5

	# 	[BigNum] $constOne = ([BigNum]1).CloneWithNewResolution($wrkRes)
	# 	[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)

	# 	[BigNum] $sqrtPart  = [BigNum]::Sqrt(($tmpVal * $tmpVal) - $constOne)
	# 	[BigNum] $arccoshVal = [BigNum]::Ln($tmpVal + $sqrtPart)

	# 	return $arccoshVal.Truncate($targetRes)
	# }

	# # Arctanh: Inverse Hyperbolic Tangent Function.
	# static [BigNum] Arctanh([BigNum] $val) {

	# 	# Arctanh is defined on ]−1, 1[

	# 	[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
	# 	[System.Numerics.BigInteger] $wrkRes = $targetRes +5
	# 	[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)
	# 	[BigNum] $absVal = $tmpVal.Abs().CloneWithNewResolution($wrkRes)

	# 	if ($absVal -ge 1) {
	# 		throw "Error in [BigNum]::Arctanh : magnitude of val must be strictly smaller than 1"
	# 	}

	# 	[BigNum] $constOne = ([BigNum]1).CloneWithNewResolution($wrkRes)
	# 	[BigNum] $constHalf = ([BigNum]"0.5").CloneWithNewResolution($wrkRes)
	# 	[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)

	# 	[BigNum] $arctanhVal = $constHalf * [BigNum]::Ln($($constOne + $tmpVal) / ($constOne - $tmpVal))

	# 	return $arctanhVal.Truncate($targetRes)
	# }

	# # Arccsch: Inverse Hyperbolic Cosecant Function.
	# static [BigNum] Arccsch([BigNum] $val) {

	# 	# Arccsch is defined on R*

	# 	if ($val.IsNull()) {
	# 		throw "Error in [BigNum]::Arccsch : val must not be null"
	# 	}

	# 	[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
	# 	[System.Numerics.BigInteger] $wrkRes = $targetRes +5

	# 	[BigNum] $constOne = ([BigNum]1).CloneWithNewResolution($wrkRes)
	# 	[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)

	# 	[BigNum] $invX = $constOne / $tmpVal
	# 	[BigNum] $sqrtPart = [BigNum]::Sqrt(($invX * $invX) + $constOne)
	# 	[BigNum] $arccschVal = [BigNum]::Ln($invX + $sqrtPart)

	# 	return $arccschVal.Truncate($targetRes)
	# }

	# # Arcsech: Inverse Hyperbolic Secant Function.
	# static [BigNum] Arcsech([BigNum] $val) {

	# 	# Arcsech is defined on ]0, 1]

	# 	if (($val -le 0) -or ($val -gt 1)) {
	# 		throw "Error in [BigNum]::Arcsech : val must be greater than 0 and smaller or equal to 1"
	# 	}

	# 	[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
	# 	[System.Numerics.BigInteger] $wrkRes = $targetRes +5

	# 	[BigNum] $constOne = ([BigNum]1).CloneWithNewResolution($wrkRes)
	# 	[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)

	# 	[BigNum] $invX = $constOne / $tmpVal
	# 	[BigNum] $sqrtPart = [BigNum]::Sqrt(($invX * $invX) - $constOne)
	# 	[BigNum] $arcsechVal = [BigNum]::Ln($invX + $sqrtPart)

	# 	return $arcsechVal.Truncate($targetRes)
	# }

	# # Arccoth: Inverse Hyperbolic Cotangent Function.
	# static [BigNum] Arccoth([BigNum] $val) {

	# 	# Arccoth is defined on ]-Inf, −1] U [1, +Inf[

	# 	if ($val.Abs() -le 1) {
	# 		throw "Error in [BigNum]::Arccoth : magnitude of val must be greater than 1"
	# 	}
		
	# 	[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
	# 	[System.Numerics.BigInteger] $wrkRes = $targetRes +5

	# 	[BigNum] $constOne = ([BigNum]1).CloneWithNewResolution($wrkRes)
	# 	[BigNum] $constHalf = ([BigNum]"0.5").CloneWithNewResolution($wrkRes)
	# 	[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)

	# 	[BigNum] $arccothVal = $constHalf * [BigNum]::Ln($($tmpVal + $constOne) / ($tmpVal - $constOne))

	# 	return $arccothVal.Truncate($targetRes)
	# }

	#endregion static Hyperbolic Trigonometry Methods



	#region instance Methods

	# Conjugate : Return a clone containing the conjugate original BigNum.
	[BigComplex] Conjugate() {
        return [BigComplex]::new($this.realPart, -$this.imaginaryPart)
    }

	# Abs : Alias of Magnitude.
	[BigNum] Abs() {
		return $this.Magnitude()
	}

	# Magnitude : Return the Magnitude (Modulus) of the original BigNum.
	[BigNum] Magnitude() {
		return [BigNum]::Sqrt($this.MagnitudeSquared())
	}

	# MagnitudeSquared : Return the squared Magnitude (Modulus) of the original BigNum.
	[BigNum] MagnitudeSquared() {
        return [BigNum]::Pow($this.realPart, 2) + [BigNum]::Pow($this.imaginaryPart, 2)
    }

	# Arg : Return a BigNum containing the argument of the original BigNum in ]-Pi,Pi].
	[BigNum] Arg() {
		if($this.IsNull()) {
			throw "[BigComplex]::Arg() : not defined for z = 0"
		}
		$tmpAtan2 = [BigNum]::Atan2($this.imaginaryPart, $this.realPart)
		
		If($this.IsPureReal() -and $this.IsStrictlyNegative()) {
		 	$tmpAtan2 = [BigNum]::Pi($this.GetMaxDecimalResolution())
		}
        return $tmpAtan2.Clone()
    }

	# PosArg : Return a BigNum containing the argument of the original BigNum in [0,Tau[.
	[BigNum] PosArg() {
		if($this.IsNull()) {
			throw "[BigComplex]::Arg() : not defined for z = 0"
		}
		$tmpAtan2 = [BigNum]::Atan2($this.imaginaryPart, $this.realPart)

		If($this.IsPureReal() -and $this.realPart.IsStrictlyNegative()) {
		 	$tmpAtan2 = [BigNum]::Pi($this.GetMaxDecimalResolution())
		}
		
		if ($tmpAtan2.IsStrictlyNegative()) {
			$tmpAtan2 += [BigNum]::Tau($this.GetMaxDecimalResolution())
		}

        return $tmpAtan2.Clone()
    }

	# Real : Return a BigNum contaning the real part of the original value.
	[BigNum] Real() {
		return $this.realPart.Clone()
	}

	# Imaginary : Return a BigNum contaning the imaginary part of the original value.
	[BigComplex] Imaginary() {
		return [BigComplex]::new(0,$this.imaginaryPart)
	}

	# ImaginaryFactor : Return a BigNum contaning the imaginary factor of the original value.
	[BigNum] ImaginaryFactor() {
		return $this.imaginaryPart.Clone()
	}

	# FractionalPart : Return a clone containing the Fractional Part of the original BigNum.
	[BigComplex] FractionalPart() {
		$tmpVal = $this.Clone()

		[BigNum] $tmpRe = $tmpVal.realPart.Clone()
		[BigNum] $tmpIm = $tmpVal.imaginaryPart.Clone()

		$tmpRe -= $tmpRe.Truncate(0)
		$tmpIm -= $tmpIm.Truncate(0)

		return [BigComplex]::new($tmpRe,$tmpIm)
	}

	# Round : Return a clone of the original BigNum rounded to $decimals digits, using the half-up rule.
	[BigComplex] Round([System.Numerics.BigInteger]$decimals){
		return [BigComplex]::new($this.realPart.Round($decimals),$this.imaginaryPart.Round($decimals))
	}

	# Ceiling : Return a clone of the original BigNum rounded to $decimals digits, using the always up rule.
	[BigComplex] Ceiling([System.Numerics.BigInteger]$decimals){
		return [BigComplex]::new($this.realPart.Ceiling($decimals),$this.imaginaryPart.Ceiling($decimals))
	}

	# Floor : Return a clone of the original BigNum rounded to $decimals digits, using the always down rule.
	[BigComplex] Floor([System.Numerics.BigInteger]$decimals){
		return [BigComplex]::new($this.realPart.Floor($decimals),$this.imaginaryPart.Floor($decimals))
	}

	# RoundAwayFromZero : Return a clone of the original BigNum rounded to $decimals digits, using the always Away-From-Zero rule.
	[BigComplex] RoundAwayFromZero([System.Numerics.BigInteger]$decimals){
		return [BigComplex]::new($this.realPart.RoundAwayFromZero($decimals),$this.imaginaryPart.RoundAwayFromZero($decimals))
	}

	# Truncate : Return a clone of the original BigNum truncated to $decimals digits. This function doest not round, just cut.
	[BigComplex] Truncate([System.Numerics.BigInteger]$decimals) {
		return [BigComplex]::new($this.realPart.Truncate($decimals),$this.imaginaryPart.Truncate($decimals))
	}

	#endregion instance Methods

}


class BigNum : System.IFormattable, System.IComparable, System.IEquatable[object] {

	hidden [System.Numerics.BigInteger] $integerVal
	hidden [System.Numerics.BigInteger] $shiftVal
	hidden [bool] $negativeFlag
	hidden [System.Numerics.BigInteger] $maxDecimalResolution
	hidden static [System.Numerics.BigInteger] $defaultMaxDecimalResolution = 100
	hidden static [BigNum] $cachedE
	hidden static [BigNum] $cachedPi
	hidden static [BigNum] $cachedTau
	hidden static [BigNum] $cachedPhi
	hidden static [hashtable] $cachedBernoulliNumberB = @{}  # n -> @{num=BigInteger; den=BigInteger}
	hidden static [BigNum] $cachedEulerMascheroniGamma
	hidden static [BigNum] $cachedSqrt2
	hidden static [BigNum] $cachedSqrt3
	hidden static [BigNum] $cachedCbrt2
	hidden static [BigNum] $cachedCbrt3


	
	#region Constructors

	# BigNum : (BigInteger,BigInteger,bool,BigInteger) Standard Constructor with all possible parameters.
	BigNum([System.Numerics.BigInteger]$intVal,[System.Numerics.BigInteger]$shift,[bool]$isNegative,[System.Numerics.BigInteger]$resolution) {
		$this.Init($intVal,$shift,$isNegative,$resolution)
    }

	# BigNum : () Standard Empty Constructor, returns a null BigNum.
	BigNum() {
		$this.Init(0,0,$false,[BigNum]::defaultMaxDecimalResolution)
    }

	# BigNum : (string) Standard string Constructor. Uses the extractFromString function.
	BigNum([string]$newVal) {
        $this.extractFromString($newVal)
    }

	# BigNum : (Int32) Standard int Constructor.
	BigNum([Int32]$newVal) {
        $this.Init($newVal,0,$false,[BigNum]::defaultMaxDecimalResolution)
    }

	# BigNum : (Int64) Standard int Constructor.
	BigNum([Int64]$newVal) {
        $this.Init($newVal,0,$false,[BigNum]::defaultMaxDecimalResolution)
    }

	# BigNum : (float) Standard float Constructor. Uses the extractFromDouble function.
	BigNum([float]$newVal) {
		$this.extractFromDouble($newVal)
    }

	# BigNum : (double) Standard float Constructor. Uses the extractFromDouble function.
	BigNum([double]$newVal) {
		$this.extractFromDouble($newVal)
    }

	# BigNum : (decimal) Standard float Constructor. Uses the extractFromDecimal function.
	BigNum([decimal]$newVal) {
        $this.extractFromDecimal($newVal)
    }

	# BigNum : (BigInteger) Standard BigInteger Constructor.
	BigNum([System.Numerics.BigInteger]$newVal) {
        $this.Init($newVal,0,$false,[BigNum]::defaultMaxDecimalResolution)
    }

	# BigNum : (BigNum) Standard BigNum Constructor.
	BigNum([BigNum]$newVal) {
        $this.Init($newVal.integerVal,$newVal.shiftVal,$newVal.negativeFlag,$newVal.maxDecimalResolution)
    }

	# BigNum : (BigNum,BigInteger) BigNum Constructor with custom resolution.
	BigNum([BigNum]$newVal,[System.Numerics.BigInteger]$newResolution) {
        $this.Init($newVal.integerVal,$newVal.shiftVal,$newVal.negativeFlag,$newResolution)
    }

	# BigNum : (BigInteger,BigInteger) BigNum Constructor with decimaly-shifted BigInteger value.
	BigNum([System.Numerics.BigInteger]$newVal,[System.Numerics.BigInteger]$newShift) {
		$this.Init($newVal,$newShift,$false,[BigNum]::defaultMaxDecimalResolution+$newShift)
    }

	# BigNum : (BigInteger,BigInteger,BigInteger) BigNum Constructor with decimaly-shifted BigInteger value and custom resolution.
	BigNum([System.Numerics.BigInteger]$newVal,[System.Numerics.BigInteger]$newShift,[System.Numerics.BigInteger]$newResolution) {
		$this.Init($newVal,$newShift,$false,$newResolution)
    }

	#endregion Constructors



	#region Init and Extractors

	# Init : INTERNAL USE. Initialise and clean up all internal values of a BigNum instance.
	hidden [void] Init([System.Numerics.BigInteger]$intVal,[System.Numerics.BigInteger]$shift,[bool]$isNegative,[System.Numerics.BigInteger]$resolution) {
		$newNegative = $isNegative
		$tmpIntegerVal = [System.Numerics.BigInteger]::Abs($intVal)
		$tmpShift = [System.Numerics.BigInteger]::Parse($shift)

		if ($intVal -lt 0) {
			$newNegative = -not $newNegative
		}

		if($shift -lt 0){
			$shiftFactor = [BigNum]::PowTenPositive($shift*(-1))
			$tmpIntegerVal *= $shiftFactor
			$tmpShift = [System.Numerics.BigInteger]::Parse(0)
		}
		
		#region CleanUp
		$tmpString = $tmpIntegerVal.ToString()
		$tmpCount = [System.Numerics.BigInteger]::Parse($tmpShift)

		if($tmpCount -gt $resolution) {
			$newEnd = $tmpString.Length - ($tmpCount - $resolution)
			if ($newEnd -gt 0) {
				$tmpString = $tmpString.Substring(0,$newEnd)
				$tmpCount = $resolution
			}else {
				$tmpString = "0"
				$tmpCount = 0
			}
		}

		while (($tmpCount -gt 0) -and ($tmpString[-1] -eq '0') -and ($tmpString.Length -gt 1)) {
			$tmpString = $tmpString.Substring(0,$tmpString.Length-1)
			$tmpCount -= 1
		}

		$tmpIntegerVal = [System.Numerics.BigInteger]::Parse($tmpString)

		if($tmpIntegerVal -eq 0){
			$tmpCount = 0
			$newNegative = $false
		}
		$tmpString = $tmpIntegerVal.ToString()

		#endregion CleanUp

		$this.integerVal = [System.Numerics.BigInteger]::Parse($tmpString)
        $this.shiftVal = [System.Numerics.BigInteger]::Parse($tmpCount)
		$this.negativeFlag = $newNegative
		$this.maxDecimalResolution = [System.Numerics.BigInteger]::Parse($resolution)
    }

	# extractFromDouble : INTERNAL USE. Initialise a BigNum instance using a signed Double as a source.
	hidden [void] extractFromDouble([double]$doubleVal) {
		$tmpNegativeFlag = $false
		$tmpIntegerVal = [System.Numerics.BigInteger]::Parse(0)
		$tmpShiftVal = [System.Numerics.BigInteger]::Parse(0)

		$strNewVal = [math]::Abs([decimal]$doubleVal).ToString([CultureInfo]::InvariantCulture).Split('.')

		if($strNewVal.Count -ne 1){
			$tmpShiftVal = $strNewVal[-1].Length
		}
		
		$tmpIntegerVal = [System.Numerics.BigInteger]::Parse($strNewVal[0])

		if ($tmpShiftVal -gt 0){
			$tmpIntegerVal *= [BigNum]::PowTenPositive($tmpShiftVal)
			$tmpIntegerVal += $strNewVal[-1]
		}

		if($doubleVal -lt 0){
			$tmpNegativeFlag = $true
		}

		$this.Init($tmpIntegerVal,$tmpShiftVal,$tmpNegativeFlag,[BigNum]::defaultMaxDecimalResolution+$tmpShiftVal)
	}

	# extractFromDecimal : INTERNAL USE. Initialise a BigNum instance using a signed Decimal as a source.
	hidden [void] extractFromDecimal([decimal]$decimalVal) {
		$tmpNegativeFlag = $false
		$tmpIntegerVal = [System.Numerics.BigInteger]::Parse(0)
		$tmpShiftVal = [System.Numerics.BigInteger]::Parse(0)

		$strNewVal = [math]::Abs($decimalVal).ToString([CultureInfo]::InvariantCulture).Split('.')

		if($strNewVal.Count -ne 1){
			$tmpShiftVal = $strNewVal[-1].Length
		}
		
		$tmpIntegerVal = [System.Numerics.BigInteger]::Parse($strNewVal[0])

		if ($tmpShiftVal -gt 0){
			$tmpIntegerVal *= [BigNum]::PowTenPositive($tmpShiftVal)
			$tmpIntegerVal += $strNewVal[-1]
		}

		if($decimalVal -lt 0){
			$tmpNegativeFlag = $true
		}

		$this.Init($tmpIntegerVal,$tmpShiftVal,$tmpNegativeFlag,[BigNum]::defaultMaxDecimalResolution+$tmpShiftVal)
	}

	# extractFromString : INTERNAL USE. Initialise a BigNum instance using a String as a source.
	hidden [void] extractFromString([string]$stringVal) {
		$numberFormat = (Get-Culture).NumberFormat
		$deciChar = $numberFormat.NumberDecimalSeparator
		$negChar = $numberFormat.negativeSign

		$tmpNegativeFlag = $false
		$tmpIntegerVal = [System.Numerics.BigInteger]::Parse(0)
		$tmpShiftVal = [System.Numerics.BigInteger]::Parse(0)

		if(($stringVal[0] -eq $negChar[0]) -or ($stringVal[-1] -eq $negChar[0]))
		{
			$tmpNegativeFlag = $true
		}

		$cleanStr = "" + "0" + $stringVal -replace ('[\.|\'+$deciChar+']'), '.'
		$cleanStr = $cleanStr -replace ('[^0-9\.]'), ''

		if ($cleanStr.LastIndexOf('.') -ne -1) {
			$tmpShiftVal = $cleanStr.Length - ($cleanStr.LastIndexOf('.') + 1)
		}

		$intStr = $cleanStr -replace ('[^0-9]'), ''
		$tmpIntegerVal = [System.Numerics.BigInteger]::Parse($intStr)

		$this.Init($tmpIntegerVal,$tmpShiftVal,$tmpNegativeFlag,[BigNum]::defaultMaxDecimalResolution+$tmpShiftVal)
	}

	#endregion Init and Extractors



	#region Debug Accessors

	# # getIntegerVal : Peek inside the BigNum object and return the internal BigInteger object stored.
	# [System.Numerics.BigInteger]getIntegerVal(){
	# 	return [System.Numerics.BigInteger]::Parse($this.integerVal)
	# }
	
	# # getShiftVal : Peek inside the BigNum object and return the internal decimal shift value.
	# [System.Numerics.BigInteger]getShiftVal(){
	# 	return [System.Numerics.BigInteger]::Parse($this.shiftVal)
	# }

	#endregion Debug Accessors
	
	
	
	#region direct Accessors and evaluation tools

	# GetMaxDecimalResolution : returns the maximum allowed decimal expansion of the BigNum.
	[System.Numerics.BigInteger]GetMaxDecimalResolution(){
		return [System.Numerics.BigInteger]::Parse($this.maxDecimalResolution)
	}

	# getDecimalExpantionLength : returns the current decimal expansion of the BigNum.
	[System.Numerics.BigInteger]getDecimalExpantionLength(){
		return [System.Numerics.BigInteger]::Parse($this.shiftVal)
	}

	# IsStrictlyNegative : returns $true only if the number is strictly negative.
	[bool] IsStrictlyNegative(){
		return ($this.negativeFlag)
	}

	# IsNegative : returns $true if the number is negative or null.
	[bool] IsNegative(){
		return (($this.negativeFlag) -or ($this.integerVal -eq 0))
	}

	# IsStrictlyPositive : returns $true only if the number is strictly positive.
	[bool] IsStrictlyPositive(){
		return ((-not $this.negativeFlag) -and ($this.integerVal -gt 0))
	}

	# IsPositive : returns $true if the number is positive or null.
	[bool] IsPositive(){
		return (-not $this.negativeFlag)
	}

	# IsNull : returns $true if the number is null.
	[bool] IsNull(){
		return ($this.integerVal -eq 0)
	}

	# IsNotNull : returns $true if the number is not null.
	[bool] IsNotNull(){
		return ($this.integerVal -ne 0)
	}

	# IsInteger : returns $true if the number has no decimal expansion.
	[bool] IsInteger() {
		if ($this.shiftVal -eq 0) {
			return $true
		}
		return $false
	}

	# HasDecimals : returns $true if the number has any decimal expansion.
	[bool] HasDecimals() {
		if ($this.shiftVal -ne 0) {
			return $true
		}
		return $false
	}

	#endregion direct Accessors and evaluation tools
	
	
	
	#region Cloning and Resolution Tools

	# Clone : returns a new instance of BigNum.
	[BigNum] Clone() {
		return [BigNum]::new($this.integerVal,$this.shiftVal,$this.negativeFlag,$this.maxDecimalResolution)
	}

	# CloneFromObject : (object) Create and return a BigNum object using any approriate Constructor.
	static [BigNum] CloneFromObject([object] $val) {
		return [BigNum]::new($val)
	}

	# CloneWithNewResolution : returns a new instance of BigNum with the maximum resolution altered, Trucate if needed.
	[BigNum] CloneWithNewResolution([System.Numerics.BigInteger] $newResolution) {
		return [BigNum]::new($this.integerVal,$this.shiftVal,$this.negativeFlag,$newResolution)
	}

	# CloneWithStandardResolution : returns a new instance of BigNum with the maximum resolution set to the default one.
	[BigNum] CloneWithStandardResolution() {
		return [BigNum]::new($this.integerVal,$this.shiftVal,$this.negativeFlag,[BigNum]::defaultMaxDecimalResolution)
	}

	# CloneWithAdjustedResolution : returns a new instance of BigNum with the maximum resolution set to the current length of the decimal expansion.
	[BigNum] CloneWithAdjustedResolution(){
		return $this.CloneWithNewResolution($this.shiftVal)
	}

	# CloneWithAddedResolution : returns a new instance of BigNum with the maximum resolution set to the current length of the decimal expansion.
	[BigNum] CloneWithAddedResolution([System.Numerics.BigInteger]$val){
		#this add $val to the max resolution of the number
		if($val -lt 0) {
			throw "Error in [BigNum]::CloneWithAddedResolution : val must be positive"
		}

		return $this.CloneWithNewResolution($this.maxDecimalResolution + $val)
	}

	# CloneAndReducePrecisionBy : returns a new instance of BigNum with the maximum resolution reduiced by $length and the number rounded if needed.
	[BigNum] CloneAndReducePrecisionBy([System.Numerics.BigInteger]$length){
		#this shorten the resolution by $val amount, and rounds if necessary
		if($length -lt 0) {
			throw "Error in [BigNum]::CloneAndReducePrecisionBy : length must be positive or null"
		}
		$newLength = $this.maxDecimalResolution - $length
		$tmpVal = $this.Round($newLength)

		return $tmpVal.CloneWithNewResolution([System.Numerics.BigInteger]::Max(0,$newLength))
	}

	#endregion Cloning and Resolution Tools



	#region Standard Interface Implementations

	# CompareTo : IComparable Implementation. Allows for the use of -lt, -le, -ge, and -gt operators.
	[int] CompareTo([object] $other) {
		# Simply perform (case-insensitive) lexical comparison on the .Kind
		# property values.
		if ($null -eq $other) {return 1}

		if ($other.GetType() -eq $this.GetType()) {
			[BigNum] $tmpOther = $other.Clone()
		} else {
			[BigNum] $tmpOther = [BigNum]::CloneFromObject($other)
		}

		if (($this.integerVal -eq $tmpOther.integerVal) -and ($this.shiftVal -eq $tmpOther.shiftVal) -and ($this.negativeFlag -eq $tmpOther.negativeFlag)) { return 0 }

		[System.Numerics.BigInteger]$tmpThis = $this.integerVal
		[System.Numerics.BigInteger]$tmpOtherInt = $tmpOther.integerVal
		
		if ($this.negativeFlag) { $tmpThis *= -1 }
		if ($tmpOther.negativeFlag) { $tmpOtherInt *= -1 }

		if ($this.shiftVal -ne $tmpOther.shiftVal) {
			if ($this.shiftVal -gt $tmpOther.shiftVal) {
				$shiftDifference = $this.shiftVal - $tmpOther.shiftVal
				$shiftFactor = [BigNum]::PowTenPositive($shiftDifference)
				$tmpOtherInt *= $shiftFactor
			}else{
				$shiftDifference = $tmpOther.shiftVal - $this.shiftVal
				$shiftFactor = [BigNum]::PowTenPositive($shiftDifference)
				$tmpThis *= $shiftFactor
			}
		}
		if ($tmpThis -lt $tmpOtherInt) {return -1 }

		return 1 # -gt
    }

	# Equals : IEquatable Implementation. Allows for the use of -eq, and -ne operators.
	[bool] Equals([object] $other) {
		$isEqual = $true
		
		if ($other.GetType() -eq $this.GetType()) {
			[BigNum] $tmpOther = $other.Clone()
		} else {
			[BigNum] $tmpOther = [BigNum]::CloneFromObject($other)
		}

		if($this.integerVal -ne $tmpOther.integerVal){
			$isEqual = $false
		}
		if($this.shiftVal -ne $tmpOther.shiftVal){
			$isEqual = $false
		}
		if($this.negativeFlag -ne $tmpOther.negativeFlag){
			$isEqual = $false
		}
		return $isEqual
    }

	# GetHashCode : IComparable Implementation. -1 if this -lt other. 0 if this -eq other. 1 if this -gt other or if other is null.
	[int] GetHashCode() {
		return $this.ToString().GetHashCode()
    }

	# op_Equality : Standard overload for the -eq operator. Not sure it ever gets called.
	static [bool] op_Equality([BigNum] $a, [BigNum] $b) {
		return ($a.Equals($b))
	}

	# op_Inequality : Standard overload for the -ne operator. Not sure it ever gets called.
	static [bool] op_Inequality([BigNum] $a, [BigNum] $b) {
		return (-not $a.Equals($b))
	}

	# ToString : IFormattable Implementation. Return a culture-aware default string representation of the original BigNum.
	[string] ToString()
	{
		$currCulture = (Get-Culture)
		return $this.ToString("G", $currCulture);
	}
	
	# ToString : IFormattable Implementation. Return a culture-aware format-specific string representation of the original BigNum.
	[string] ToString([string] $format)
	{
		$currCulture = (Get-Culture)
		return $this.ToString($format, $currCulture);
	}

	# ToString : IFormattable Implementation. Return a culture-specific default string representation of the original BigNum.
	[string] ToString([IFormatProvider] $provider)
	{
		return $this.ToString("G", $provider);
	}

	# ToString : IFormattable Implementation. Return a culture-specific, format-specific string representation of the original BigNum.
	[string] ToString([string] $format, [IFormatProvider] $provider) {
		if ($format -ne '') { $newFormat = $format }else { $newFormat = "G" }
		if ($null -ne $provider) { $newProvider = $provider }else { $newProvider = (Get-Culture) }

		$numberFormat = $newProvider.NumberFormat
		$deciChar = $numberFormat.NumberDecimalSeparator
		$negChar = $numberFormat.negativeSign
		$currencyChar = $numberFormat.CurrencySymbol

		$strBuilder = ''

		$strBuilder += $this.integerVal.ToString()
		
		if($this.shiftVal){
			while (($strBuilder.Length - $this.shiftVal) -le 0) {
				$strBuilder = $strBuilder.Insert(0,'0')
			}
			if (($strBuilder.Length - $this.shiftVal) -eq 0) {
				$deciChar = "0,"
			}
			$strBuilder = $strBuilder.Insert($strBuilder.Length - $this.shiftVal,$deciChar)
		}

		if($this.negativeFlag){
			$strBuilder = $strBuilder.Insert(0,$negChar)
		}
		
		switch ($newFormat.ToUpperInvariant())
		{
			"C" {$strBuilder += $currencyChar} # Display currency symbol , 2 digits rounded
			"D" {} # Full extend
			"E" {} # E+XXX display , 6 digits rounded
			# "EX" {return $strBuilder} # E+XXX display , X digits rounded
			"F" {} # Rounded at 3 digits, 3 decimal places minimum
			# "FX" {return $strBuilder} # Rounded at X digits, X decimal places minimum
			"G" {} # Full extend
			"N" {}
			"P" {}
			"R" {}
			"X" {throw "The X (Hex) format string is not yet supported."}
			# "0,0.000" {return $strBuilder}
			# "#,#.00#;(#,#.00#)" {return $strBuilder}
			default {throw "The $format format string is not supported."}
		}

		return $strBuilder
	}

	#endregion Standard Interface Implementations



	#region Base Operators

	# op_Addition : Standard overload for the "+" operator.
	static [BigNum] op_Addition([BigNum] $a, [BigNum] $b) {
		[System.Numerics.BigInteger]$tmpA = $a.integerVal
	  	[System.Numerics.BigInteger]$tmpB = $b.integerVal
		[System.Numerics.BigInteger]$newDecimalResolution = [System.Numerics.BigInteger]::Max($a.maxDecimalResolution,$b.maxDecimalResolution)
	  
	  	if ($a.negativeFlag) { $tmpA *= -1 }
	  	if ($b.negativeFlag) { $tmpB *= -1 }

		if ($a.shiftVal -ne $b.shiftVal) {
			if ($a.shiftVal -gt $b.shiftVal) {
				$shiftDifference = $a.shiftVal - $b.shiftVal
				$shiftFactor = [BigNum]::PowTenPositive($shiftDifference)
				$tmpB *= $shiftFactor
			}else{
				$shiftDifference = $b.shiftVal - $a.shiftVal
				$shiftFactor = [BigNum]::PowTenPositive($shiftDifference)
				$tmpA *= $shiftFactor
			}
		}

		return [BigNum]::new($tmpA + $tmpB,[System.Numerics.BigInteger]::Max($a.shiftVal,$b.shiftVal)).CloneWithNewResolution($newDecimalResolution)
	}

	# op_Subtraction : Standard overload for the "-" operator.
	static [BigNum] op_Subtraction([BigNum] $a, [BigNum] $b) {
		[System.Numerics.BigInteger]$tmpA = $a.integerVal
	  	[System.Numerics.BigInteger]$tmpB = $b.integerVal
		[System.Numerics.BigInteger]$newDecimalResolution = [System.Numerics.BigInteger]::Max($a.maxDecimalResolution,$b.maxDecimalResolution)
	  
	  	if ($a.negativeFlag) { $tmpA *= -1 }
	  	if ($b.negativeFlag) { $tmpB *= -1 }

		if ($a.shiftVal -ne $b.shiftVal) {
			if ($a.shiftVal -gt $b.shiftVal) {
				$shiftDifference = $a.shiftVal - $b.shiftVal
				$shiftFactor = [BigNum]::PowTenPositive($shiftDifference)
				$tmpB *= $shiftFactor
			}else{
				$shiftDifference = $b.shiftVal - $a.shiftVal
				$shiftFactor = [BigNum]::PowTenPositive($shiftDifference)
				$tmpA *= $shiftFactor
			}
		}

		return [BigNum]::new($tmpA - $tmpB,[System.Numerics.BigInteger]::Max($a.shiftVal,$b.shiftVal)).CloneWithNewResolution($newDecimalResolution)
	}

	# op_Multiply : Standard overload for the "*" operator.
	static [BigNum] op_Multiply([BigNum] $a, [BigNum] $b) {
		[System.Numerics.BigInteger]$tmpA = $a.integerVal
	  	[System.Numerics.BigInteger]$tmpB = $b.integerVal
		[System.Numerics.BigInteger]$newDecimalResolution = [System.Numerics.BigInteger]::Max($a.maxDecimalResolution,$b.maxDecimalResolution)
	  
	  	if ($a.negativeFlag) { $tmpA *= -1 }
	  	if ($b.negativeFlag) { $tmpB *= -1 }

		return [BigNum]::new($tmpA * $tmpB,$a.shiftVal + $b.shiftVal,$newDecimalResolution)
	}

	# op_Division : Standard overload for the "/" operator.
	static [BigNum] op_Division([BigNum] $a, [BigNum] $b) {
		if ($b.IsNull()) {
			throw "Error in [BigNum]::op_Division : Divisor operand must not be null"
		}
		[System.Numerics.BigInteger]$tmpA = $a.integerVal
	  	[System.Numerics.BigInteger]$tmpB = $b.integerVal
		[System.Numerics.BigInteger]$newDecimalResolution = [System.Numerics.BigInteger]::Max($a.maxDecimalResolution,$b.maxDecimalResolution)

	  	if ($a.negativeFlag) { $tmpA *= -1 }
	  	if ($b.negativeFlag) { $tmpB *= -1 }

		$tmpA *= [BigNum]::PowTenPositive($newDecimalResolution + $b.shiftVal)

		return [BigNum]::new($tmpA / $tmpB,$newDecimalResolution + $a.shiftVal,$newDecimalResolution)
	}

	# op_Modulus : Standard overload for the "%" operator.
	static [BigNum] op_Modulus([BigNum] $a, [BigNum] $b) {

		[BigNum]$tmpA = $a.Clone()
		[BigNum]$tmpB = $b.Clone()

		[System.Numerics.BigInteger]$newDecimalResolution = [System.Numerics.BigInteger]::Max($a.maxDecimalResolution,$b.maxDecimalResolution)
		[System.Numerics.BigInteger]$tmpDiv = [BigNum]::EuclideanDiv($tmpA,$tmpB)
		[BigNum]$tmpResult = $tmpA - ($tmpB*$([BigNum]::CloneFromObject($tmpDiv)))
		return $tmpResult.CloneWithNewResolution($newDecimalResolution)
	}

	# op_LeftShift : Standard overload for the "<<" operator.
	static [BigNum] op_LeftShift([BigNum] $a, [System.Numerics.BigInteger] $b) {
		[System.Numerics.BigInteger]$tmpA = $a.integerVal
		[System.Numerics.BigInteger]$newShiftVal = $a.shiftVal - $b

		if ($newShiftVal -lt 0) {
			$tmpA *= [BigNum]::PowTenPositive(-$newShiftVal)
			$newShiftVal=0
		}

		return [BigNum]::new($tmpA,$newShiftVal,$a.negativeFlag,$a.GetMaxDecimalResolution())
	}

	# op_LeftShift : Standard overload for the ">>" operator.
	static [BigNum] op_RightShift([BigNum] $a, [System.Numerics.BigInteger] $b) {
		[System.Numerics.BigInteger]$tmpA = $a.integerVal
		[System.Numerics.BigInteger]$newShiftVal = $a.shiftVal + $b

		return [BigNum]::new($tmpA,$newShiftVal,$a.negativeFlag,$a.GetMaxDecimalResolution())
	}

	# -bxor   op_ExclusiveOr
	# -band   op_BitwiseAnd
	# -bor    op_BitwiseOr
	# -bnot   op_OnesComplement

	#endregion Base Operators



	#region internals private methods

	# EstimateTaylorTermsForLn : INTERNAL USE. Returns the number of iteration required for the Taylor series in the Ln function.
	hidden static [System.Numerics.BigInteger] EstimateTaylorTermsForLn([BigNum] $x, [System.Numerics.BigInteger] $decimalLength) {
		[System.Numerics.BigInteger] $n = 1
		[System.Numerics.BigInteger] $targetDecimalLength = [System.Numerics.BigInteger]::Max($decimalLength,$x.maxDecimalResolution)+10
		[BigNum] $targetEpsilon = [BigNum]::new("1",$targetDecimalLength,$false,$targetDecimalLength)
		[BigNum] $currentPower = $x.CloneWithNewResolution($targetDecimalLength)

		while (($currentPower.Abs() / $n) -gt $targetEpsilon) {
			$n += 1
			$currentPower *= $x
		}

		return $n
	}

	# EstimateTaylorTermsForExp : INTERNAL USE. Returns the number of iteration required for the Taylor series in the Exp function.
	hidden static [System.Numerics.BigInteger] EstimateTaylorTermsForExp([BigNum] $x, [System.Numerics.BigInteger] $decimalLength) {
		#This function requires a scaled $x value
		[System.Numerics.BigInteger] $n = 1
		[System.Numerics.BigInteger] $targetDecimalLength = [System.Numerics.BigInteger]::Max($decimalLength,$x.maxDecimalResolution)+10
		[BigNum] $absX = $x.Abs().CloneWithNewResolution($targetDecimalLength)
		[BigNum] $term = $absX.CloneWithNewResolution($targetDecimalLength)
		[BigNum] $factorial = [BigNum]::CloneFromObject("1").CloneWithNewResolution($targetDecimalLength)
		[BigNum] $targetEpsilon = [BigNum]::new(1,$decimalLength,$false,$targetDecimalLength)
		[System.Numerics.BigInteger] $hardLimit = 10000

		while ((($term / $factorial) -gt $targetEpsilon) -and ($n -lt $hardLimit)) {
			$n += 1
			$term *= $absX
			$factorial *= [BigNum]::CloneFromObject($n).CloneWithNewResolution($targetDecimalLength)
		}

		if ($n -ge $hardLimit) {
			throw "[BigNum]::EstimateTaylorTermsForExp reached hard limit ($hardLimit) without convergence"
		}

		return $n
	}

	# SpouseChooseA: INTERNAL USE. Heuristic a depending on the number of digits requested
    hidden static [System.Numerics.BigInteger] SpouseChooseA([System.Numerics.BigInteger] $resolutions) {
        $ln2pi = [BigNum]::Ln(([BigNum]2).CloneWithNewResolution($resolutions) * [BigNum]::Pi($resolutions))
		$ln10  = [BigNum]::Ln(10)
        $aEst  = (((([BigNum]$resolutions).CloneWithNewResolution($resolutions) * $ln10) / $ln2pi).Ceiling(0) + ([BigNum]10)).Int()
		return [BigNum]::Max($aEst, 10).Int()
    }

	#endregion internals private methods



	#region static Operators and Methods

	# Min : return a clone of the smalest object
	static [BigNum] Min([BigNum] $a,[BigNum] $b) {
		if ($a -lt $b) {
			return $a.Clone()
		}
		return $b.Clone()
	}

	# Max : return a clone of the biggest object
	static [BigNum] Max([BigNum] $a,[BigNum] $b) {
		if ($a -gt $b) {
			return $a.Clone()
		}
		return $b.Clone()
	}

	# EuclideanDiv : Returns the Euclidean Div as a BigInteger.
	static [System.Numerics.BigInteger] EuclideanDiv([BigNum] $a, [BigNum] $b) {
		if ($b.IsNull()) {
			throw "Error in [BigNum]::EuclideanDiv : Divisor must not be null"
		}

		[BigNum] $tmpA = $a.CloneWithAdjustedResolution().CloneWithAddedResolution(10)
		[BigNum] $tmpB = $b.CloneWithAdjustedResolution().CloneWithAddedResolution(10)

		return ($tmpA/$tmpB).Floor(0).Int()
	}

	# Ln : Returns the Natural Logarithm (Logarithme Neperien) in base e for $value.
	static [BigNum] Ln([BigNum] $value) {
		# Trap illegal values
		if ($value -le 0) {
			throw "[BigNum]::Ln() function is not defined for zero nor negative numbers"
		}

		$tmpResolution = $value.maxDecimalResolution + 100
		
		[BigNum] $tmpVal = $value.CloneWithNewResolution($tmpResolution)
		[BigNum] $tmpOne = [BigNum]::new("1.0").CloneWithNewResolution($tmpResolution)
		[BigNum] $tmpQuarter = [BigNum]::new("0.25").CloneWithNewResolution($tmpResolution)
		[System.Numerics.BigInteger] $powerAdjust = [System.Numerics.BigInteger]::Parse(0);

		# Confine x to a sensible range
		while ($tmpVal -gt $tmpOne) {
			$tmpVal /= [BigNum]::e($tmpResolution)
			$powerAdjust += 1
		}
		while ($tmpVal -lt $tmpQuarter) {
			$tmpVal *= [BigNum]::e($tmpResolution)
			$powerAdjust -= 1
		}
		
		# Now use the Taylor series to calculate the logarithm
		$tmpVal -= 1
		[System.Numerics.BigInteger] $TAYLOR_ITERATIONS = [BigNum]::EstimateTaylorTermsForLn($tmpVal,$tmpResolution)
		[BigNum] $tmpT = [BigNum]::new(0).CloneWithNewResolution($tmpResolution)
		[BigNum] $tmpS = [BigNum]::new(1).CloneWithNewResolution($tmpResolution)
		[BigNum] $tmpZ = $tmpVal.CloneWithNewResolution($tmpResolution)

		for ([BigNum]$k = 1; $k -le $TAYLOR_ITERATIONS; $k += 1) {
			$tmpT += $tmpZ * $tmpS / $k
			$tmpZ *= $tmpVal
			$tmpS *= -1
		}
		
		# Combine the result with the power_adjust value and return
		return [BigNum]::new($tmpT+$powerAdjust).Truncate($value.maxDecimalResolution).CloneWithNewResolution($value.maxDecimalResolution)
	}

	# Exp : Returns the value of e to the power $exponent.
	static [BigNum] Exp([BigNum] $exponent) {

		# threshold where we start scaling
		$threshold = [BigNum]::new(1)

		$tmpResolution = $exponent.maxDecimalResolution + 100

		[BigNum] $absX = $exponent.Abs()
		[System.Numerics.BigInteger] $k = 0
		$constTwo = ([BigNum]2).CloneWithNewResolution($tmpResolution)

		# Find k such that |x / 2^k| < threshold
		while ($absX -gt $threshold) {
			$absX /= $constTwo
			$k += 1
		}

		# Compute smallExp = e^(x / 2^k)
		$scaledX = $exponent / [BigNum]::new([System.Numerics.BigInteger]::Pow(2, $k))
		$numTerms = [BigNum]::EstimateTaylorTermsForExp($scaledX, $tmpResolution)

		[BigNum] $result = [BigNum]::new(1).CloneWithNewResolution($tmpResolution)
		[BigNum] $term = [BigNum]::new(1).CloneWithNewResolution($tmpResolution)
		[BigNum] $factorial = [BigNum]::new(1).CloneWithNewResolution($tmpResolution)

		for ([System.Numerics.BigInteger] $n = 1; $n -le $numTerms; $n += 1) {
			$term *= $scaledX
			$factorial *= [BigNum]::new($n).CloneWithNewResolution($tmpResolution)
			$result += $term / $factorial
		}

		# Square result k times
		for ([System.Numerics.BigInteger] $i = 0; $i -lt $k; $i += 1) {
			$result *= $result
		}

		return $result.Clone().Truncate($exponent.maxDecimalResolution).CloneWithNewResolution($exponent.maxDecimalResolution)
	}

	# Log : Returns the Logarithm in base $base for $value.
	static [BigNum] Log([BigNum] $base, [BigNum] $value) {
		if (($base -le 0) -or ($base -eq [BigNum]::new(1))) {
			throw "[BigNum]::Log() error: base must be positive and not equal to 1"
		}
		if ($value -le 0) {
			throw "[BigNum]::Log() error: logarithm is not defined for non-positive values"
		}

		$targetResolution = ([BigNum]::Max($value.maxDecimalResolution,$base.maxDecimalResolution)).Int()
		$tmpResolutionPlus = $targetResolution + 100

		[BigNum] $lnValue = [BigNum]::Ln($value.CloneWithNewResolution($tmpResolutionPlus))
		[BigNum] $lnBase = [BigNum]::Ln($base.CloneWithNewResolution($tmpResolutionPlus))

		return [BigNum]::new($lnValue / $lnBase).Truncate($targetResolution).CloneWithNewResolution($targetResolution)
	}

	# Pow : Returns the value of $value to the power $exponent. Dispaches to PowTen, PowTenPositive, PowInt, and PowFloat as needed.
	static [BigNum] Pow([BigNum] $base, [BigNum] $exponent) {
		if($base.IsNull()){
			return ([BigNum]0).CloneWithNewResolution([System.Numerics.BigInteger]::Max($base.maxDecimalResolution,$exponent.maxDecimalResolution))
		}

		if(($base -eq 10) -and $exponent.IsInteger()){
			return [BigNum]::PowTen($exponent.Int())
		}
		if($exponent.IsInteger() -and $exponent.IsPositive()) {
			return [BigNum]::PowInt($base, $exponent.Int())
		}
		return [BigNum]::PowFloat($base, $exponent)
	}

	# PowTen : INTERNAL USE. Returns the value of 10 to the power $exponent. $exponent must be an integer. Dispaches to PowTenPositive if needed.
	hidden static [BigNum] PowTen([System.Numerics.BigInteger] $exponent) {
		if ($exponent -ge 0) { return [BigNum]::CloneFromObject([BigNum]::PowTenPositive($exponent)) }
		$tmpExp = -$exponent
		return [BigNum]::new(1,$tmpExp,$false,$tmpExp)
	}

	# PowTenPositive : INTERNAL USE. Returns the value of 10 to the power $exponent. $exponent must be a null or positive integer.
	hidden static [System.Numerics.BigInteger] PowTenPositive([System.Numerics.BigInteger] $exponent) {
		if ($exponent -lt 0) {
			throw "[BigNum]::PowTenPositive is only to be used with positive or null exponents. For negative exponents, use [BigNum]::Pow instead."
		}

		if($exponent -eq 0) {return [System.Numerics.BigInteger]::Parse(1)}

		[System.Numerics.BigInteger] $residualExp = [System.Numerics.BigInteger]::Parse($exponent);
		[System.Numerics.BigInteger] $total = 1
		[System.Numerics.BigInteger] $maxPow = 0

     	while ($residualExp -gt [int16]::MaxValue) {
			if ($maxPow -eq 0) {
				$maxPow = [System.Numerics.BigInteger]::Pow(10, [int16]::MaxValue);
			}
        	$residualExp -= [int16]::MaxValue
        	$total *= $maxPow
     	}

     	$total *= [System.Numerics.BigInteger]::Pow(10, [int16]$residualExp)

		return [System.Numerics.BigInteger]::Parse($total)
	}

	# PowInt : INTERNAL USE. Returns the value of $value to the power $exponent. $exponent must be an integer.
	hidden static [BigNum] PowInt([BigNum] $base, [System.Numerics.BigInteger] $exponent) {
		[System.Numerics.BigInteger] $residualExp = [System.Numerics.BigInteger]::Parse($exponent);
		[System.Numerics.BigInteger] $intBase = [System.Numerics.BigInteger]::Parse($base.integerVal)
		if ($base.IsStrictlyNegative()) { $intBase *= -1 }
		[System.Numerics.BigInteger] $shiftValue = [System.Numerics.BigInteger]::Parse($base.shiftVal)
		[System.Numerics.BigInteger] $total = 1
		[System.Numerics.BigInteger] $maxPow = 0

     	while ($residualExp -gt [int16]::MaxValue) {
			if ($maxPow -eq 0) {
				$maxPow = [System.Numerics.BigInteger]::Pow($intBase, [int16]::MaxValue);
			}
        	$residualExp -= [int16]::MaxValue
        	$total *= $maxPow
     	}

     	$total *= [System.Numerics.BigInteger]::Pow($intBase, [int16]$residualExp);
		return [BigNum]::new($total,$shiftValue*$exponent,$false,$base.maxDecimalResolution)
	}

	# PowFloat : INTERNAL USE. Returns the value of $value to the power $exponent.
	hidden static [BigNum] PowFloat([BigNum] $base, [BigNum] $exponent) {
		if ($base.negativeFlag) {
			throw "[BigNum]::Pow is not capable of handling complex value output. Please use [BigComplex]::Pow() instead."
		}
		[System.Numerics.BigInteger] $newResolution = [System.Numerics.BigInteger]::Max($base.maxDecimalResolution,$exponent.maxDecimalResolution)

		return [BigNum]::new([BigNum]::Exp(($exponent*([BigNum]::Ln($base))))).CloneWithNewResolution($newResolution)
	}

	# Sqrt : Returns the value of the Square Root of $value using the Newton-Raphson algorithm.
	static [BigNum] Sqrt([BigNum] $value) {
		if ($value.IsStrictlyNegative()) {
        	throw "[BigNum]::Sqrt() is not defined for null or negative numbers"
		}

		$tmpResolution = $value.maxDecimalResolution + 10
		$tmpValue = $value.CloneWithNewResolution($tmpResolution)
		$constOne = [BigNum]::new(1).CloneWithNewResolution($tmpResolution)

		# Initial guess: S / 2 or 1 if S < 1
    	# [BigNum] $x = ($tmpValue -lt $constOne) ? $constOne.clone() : ($tmpValue / $constTwo)
		[BigNum] $x = ($tmpValue -lt $constOne) ? ([BigNum]::PowTen(-($tmpValue.shiftVal-1-$tmpValue.integerVal.ToString().Length))) : (($tmpValue.integerVal.ToString().Length%2)?([BigNum]::PowTen(($tmpValue.integerVal.ToString().Length - 1)/2)):([BigNum]::PowTen($tmpValue.integerVal.ToString().Length/2)))
		# Convergence threshold
    	[BigNum] $epsilon = [BigNum]::PowTen(-$tmpResolution).CloneWithNewResolution($tmpResolution)


		[BigNum] $half = [BigNum]::new(0.5).CloneWithNewResolution($tmpResolution)
    	[BigNum] $diff = $constOne.clone()

		do {
			$prev_x = $x
			$x = $half * ($x + ($tmpValue / $x))
			$diff = ($x - $prev_x).Abs()
		} while ($diff -gt $epsilon)

		# Return truncated to user-specified resolution
		return $x.Clone().Truncate($value.maxDecimalResolution).CloneWithNewResolution($value.maxDecimalResolution)
	}

	# Cbrt : Returns the value of the Cubic Root of $value using the Newton-Raphson algorithm.
	static [BigNum] Cbrt([BigNum] $value) {
		return [BigNum]::NthRootInt(3, $value)
	}

	# NthRoot : Returns the value of the Nth ($n) Root of $value using the Newton-Raphson algorithm. Calls NthRootInt if faster.
	static [BigNum] NthRoot([BigNum] $n, [BigNum] $value) {
		if ($n -eq 0) {
			throw "[BigNum]::NthRoot() - exponent 'n' cannot be zero"
		}

		if($n.IsInteger()) {
			return [BigNum]::NthRootInt($n.Int(), $value)
		}

		$constTwo = [BigNum]::new(2)

		if (($value -lt 0) -and ((-not $n.IsInteger()) -or (($n % $constTwo) -eq 0))) {
			throw "[BigNum]::NthRoot() - negative base with non-odd integer root leads to complex result"
		}

		$tmpResolution = $value.maxDecimalResolution + 10
		$tmpValue = $value.CloneWithNewResolution($tmpResolution)
		$x = [BigNum]::PowTen(0)

		# Initial guess: 10 ^ (numDigits / n)
		if(($tmpValue -lt 1) -and ($tmpValue -gt -1)){
			$x = [BigNum]::PowTen(-($tmpValue.shiftVal-1-$tmpValue.integerVal.ToString().Length)).CloneWithNewResolution($tmpResolution)
		} else {
			$numDigits = [BigNum]::CloneFromObject($tmpValue.integerVal.ToString().Length)
			$approxExp = $numDigits / $n
			$x = [BigNum]::PowTen($approxExp.Round(0).Int()).CloneWithNewResolution($tmpResolution)
		}

		# Precompute constants
		$constOne = [BigNum]::new(1).CloneWithNewResolution($tmpResolution)
		# $constTwo = [BigNum]::new(2).CloneWithNewResolution($tmpResolution)
		$epsilon = [BigNum]::PowTen(5-$tmpResolution)

		$diff = $x
		do {
			$xPrev = $x
			$xPowerN = [BigNum]::Pow($x, $n)
			$xPowerNminus1 = [BigNum]::Pow($x, $n - $constOne)
			$x = $x - (($xPowerN - $tmpValue) / ($n * $xPowerNminus1))
			$diff = ($x - $xPrev).Abs()
		} while ($diff -gt $epsilon)

		return $x.Truncate($value.maxDecimalResolution).CloneWithNewResolution($value.maxDecimalResolution)
	}

	# NthRootInt : Returns the value of the Nth ($n, being an integer) Root of $value using the Newton-Raphson algorithm.
	hidden static [BigNum] NthRootInt([System.Numerics.BigInteger] $n, [BigNum] $value) {
		if ($n -eq 0) {
			throw "[BigNum]::NthRootInt() - exponent 'n' cannot be zero"
		}

		if ($value -lt 0 -and (($n % 2) -eq 0)) {
			throw "[BigNum]::NthRootInt() cannot compute even roots of negative numbers"
		}

		# Setup high resolution for internal calculations
		$tmpResolution = $value.maxDecimalResolution + 10
		$tmpValue = $value.CloneWithNewResolution($tmpResolution)
		$x = [BigNum]::PowTen(0)

		# Initial guess: 10 ^ floor(numDigits / n)
		if(($tmpValue -lt 1) -and ($tmpValue -gt -1)){
			$x = [BigNum]::PowTen(-($tmpValue.shiftVal-1-$tmpValue.integerVal.ToString().Length)).CloneWithNewResolution($tmpResolution)
		} else {
			$numDigits = $tmpValue.integerVal.ToString().Length
			$approxExp = $numDigits / $n
			$x = [BigNum]::PowTen($approxExp).CloneWithNewResolution($tmpResolution)
		}

		# Precompute constants
		$nBig = [BigNum]::new($n).CloneWithNewResolution($tmpResolution)
		$nMinusOne = $nBig - 1
		$epsilon = [BigNum]::PowTen(5-$tmpResolution).CloneWithNewResolution($tmpResolution)

		# Newton-Raphson iterations
		$diff = $x
		do {
			$xPrev = $x
			$xPower = [BigNum]::Pow($x, $nMinusOne)
			$x = (($nMinusOne * $x) + ($tmpValue / $xPower)) / $nBig
			$diff = ($x - $xPrev).Abs()
		} while ($diff -gt $epsilon)

		# Return the value truncated to the requested resolution
		return $x.Truncate($value.maxDecimalResolution).CloneWithNewResolution($value.maxDecimalResolution)
	}

	# ModPow : Returns the modular exponentiation of $base raisend to the power $exponent modulo $modulus. Calls ModPowPosInt if possible.
	static [BigNum] ModPow([BigNum] $base, [BigNum] $exponent, [BigNum] $modulus) {
		if ($base.IsInteger() -and $base.IsPositive() -and $exponent.IsInteger() -and $exponent.IsPositive() -and $modulus.IsInteger() -and $modulus.IsStrictlyPositive()) {
			return ([BigNum]::CloneFromObject([BigNum]::ModPowPosInt($base.Int(),$exponent.Int(),$modulus.Int())))
		}
		return ([BigNum]::Pow($base,$exponent) % $modulus).Clone()
	}

	# ModPowPosInt : INTERNAL USE. Returns cryptographically-optimised modular exponentiation of $base raisend to the power $exponent modulo $modulus.
	static [System.Numerics.BigInteger] ModPowPosInt([System.Numerics.BigInteger] $base, [System.Numerics.BigInteger] $exponent, [System.Numerics.BigInteger] $modulus) {
		if ($base -lt 0) {
			throw "[BigNum]::ModPowPosInt() error: negative base not supported"
		}

		if ($exponent -lt 0) {
			throw "[BigNum]::ModPowPosInt() error: negative exponent not supported"
		}

		if ($modulus -le 0) {
			throw "[BigNum]::ModPowPosInt() error: modulus cannot be zero nor negative"
		}

		return [System.Numerics.BigInteger]::ModPow($base,$exponent,$modulus)
	}

	# Factorial : Returns $value Factorial. Internaly calls FactorialIntMulRange.
	static [BigNum] Factorial([BigNum] $value) {
		if (($value -eq 1) -or ($value -eq 0)) {
			return ([BigNum]1).CloneWithNewResolution($value.maxDecimalResolution)
		}

		if ($value.HasDecimals() -or $value.IsStrictlyNegative()) {
			$zp1 = ($value + 1).CloneWithNewResolution($value.maxDecimalResolution)
			return [BigNum]::Gamma($zp1).Truncate($value.maxDecimalResolution).CloneWithAdjustedResolution()
		}

		# Product 2..n (1 doesn't change)
		return ([BigNum]::new(([BigNum]::FactorialIntMulRange(2, $value.Int())),0,$false,[BigNum]::defaultMaxDecimalResolution))
	}

	# FactorialIntMulRange : INTERNAL USE. Compute the Factorial using the Split‑Recursive method.
	hidden static [System.Numerics.BigInteger] FactorialIntMulRange( [System.Numerics.BigInteger] $lo, [System.Numerics.BigInteger] $hi){
		[int] $cutoff = 64
		if ($hi -lt $lo) { return [System.Numerics.BigInteger]::One }
		if ($hi -eq $lo) { return $hi }

		# Small range: loop
		if (($hi - $lo) -lt $cutoff) {
			[System.Numerics.BigInteger]$p = [System.Numerics.BigInteger]::One
			for([System.Numerics.BigInteger]$k=$lo; $k -le $hi; $k += 1){
				$p = $p * $k
			}
			return $p
		}

		# Recursive split
		[System.Numerics.BigInteger]$mid = ($lo + $hi) / 2
		[System.Numerics.BigInteger]$left  = [BigNum]::FactorialIntMulRange($lo,  $mid)
		[System.Numerics.BigInteger]$right = [BigNum]::FactorialIntMulRange($mid+1,$hi)
		return $left * $right
	}

	# Gamma : Compute the value of the Gamma function for z.
	static [BigNum] Gamma( [BigNum] $z ){
		# integers ≤ 0  →  poles
		if ($z.IsInteger() -and $z.IsNegative()) {
			throw "[BigNum]::Gamma(): pole at negative or null integer z"
		}

		if ($z -le 0) {
			return [BigNum]::GammaNeg($z)
		}

		return [BigNum]::GammaPos($Z)
	}

	# GammaPos : INTERNAL USE. Compute the value of the Gamma function for positive $z.
	hidden static [BigNum] GammaPos( [BigNum] $z ){

		# $res = $z.maxDecimalResolution + 20

		$wrkRes = (([BigNum]$z.maxDecimalResolution)*1.1).Ceiling(0).Int()+10

		$targetResolution = $z.maxDecimalResolution

		if ($z.IsInteger()) {
			return [BigNum]::Factorial($z-1).Truncate($targetResolution)
		}

		$lnG = [BigNum]::LnGammaPos($z.CloneWithNewResolution($wrkRes))
		$G   = [BigNum]::Exp($lnG)
		return $G.Truncate($targetResolution)
	}

	# LnGammaPos : INTERNAL USE. Compute the Log base e of the Gamma function.
	hidden static [BigNum] LnGammaPos([BigNum] $z ){
		if ($z -le 0) {
			throw "[BigNum]::LnGammaPos(): z must be > 0 (use Gamma to get reflection)."
		}
		if ($z.IsInteger()) {
			throw "[BigNum]::LnGammaPos(): z must not be an integer."
		}


		[System.Numerics.BigInteger] $wrkRes = $z.maxDecimalResolution + 10
		[System.Numerics.BigInteger] $targetResolution = $z.maxDecimalResolution
		# [System.Numerics.BigInteger] $targetRes = $z.maxDecimalResolution + 5

		# Pick Spouge parameter a
        [System.Numerics.BigInteger] $selectedA = [BigNum]::SpouseChooseA($wrkRes)

		# Series S = c₀ + Σ_{k=1}^{a-1} c_k / (x-1+k)
        [BigNum] $S = [BigNum]::SpougeCoefficient(0,$selectedA,$wrkRes)
        for ([System.Numerics.BigInteger] $k = 1; $k -lt $selectedA; $k += 1) {
            [BigNum] $ck = [BigNum]::SpougeCoefficient($k,$selectedA,$wrkRes)
            [BigNum] $den  = $z - 1 + $k
            $S += ($ck / $den)
        }

		# Main terms
        $term1 = ($z - 0.5) * [BigNum]::Ln(($z + $selectedA - 1).CloneWithNewResolution($wrkRes))
        $term2 = (-($z + $selectedA - 1)).CloneWithNewResolution($wrkRes)
        $term3 = [BigNum]::Ln($S.CloneWithNewResolution($wrkRes))

		$LnGammaResult = ($term1 + $term2 + $term3)

		return $LnGammaResult.Truncate($targetResolution)
	}

	# GammaNeg : INTERNAL USE. Compute the value of the Gamma function for negative z.
	hidden static [BigNum] GammaNeg( [BigNum] $z ){

		# ---------- reflection branch (z < 0) ----------------------
		# working precision: requested + 10 guard digits
		[System.Numerics.BigInteger] $wrk = $z.GetMaxDecimalResolution() + 10
		# [bigint] $targetRes = $z.GetMaxDecimalResolution()
		[BigNum] $tmpZ = $z.CloneWithNewResolution($wrk)

		# sin(π z)
		[BigNum] $adaptPi    = [BigNum]::Pi($wrk+5)
		[BigNum] $sinPZ = [BigNum]::Sin($adaptPi * $tmpZ)  # you said sin works

		# if sin(πz) too small, raise guard digits automatically
		if ($sinPZ.Abs() -lt [BigNum]::PowTen(-($wrk+5))) {
			$wrk += 20         # adaptive bump
			[BigNum] $adaptPi    = [BigNum]::Pi($wrk+5)
			$sinPZ  = [BigNum]::Sin($adaptPi * $tmpZ)
		}

		[BigNum] $oneMinusZ = ( [BigNum]::new(1).CloneWithNewResolution($wrk) - $tmpZ )
		[BigNum] $gamma1mz  = [BigNum]::GammaPos($oneMinusZ)            # positive argument

		[BigNum] $result = ( $adaptPi / $sinPZ ) / $gamma1mz
		return $result.Clone()
	}

	#endregion static Operators and Methods

	

	#region static Trigonometry Methods

	# Sin: Sine Function.
	static [BigNum] Sin([BigNum] $val) {
		
		# Sin is defined on R

		[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		[BigNum] $constOne = ([BigNum]"1").CloneWithNewResolution($wrkRes)
		[BigNum] $constMinusOne = ([BigNum]"-1").CloneWithNewResolution($wrkRes)
		[BigNum] $constTwo = ([BigNum]"2").CloneWithNewResolution($wrkRes)
		[BigNum] $constTau = [BigNum]::Tau($wrkRes)
		
		# Preliminary: reduce x to [-π, π] range
		[BigNum] $k = ($val / $constTau).Round(0)
		$term = $val - $k * $constTau

		[BigNum] $sum = $term.Clone()
		[BigNum] $x2 = $sum * $sum
		[System.Numerics.BigInteger] $n = 1

		[BigNum] $target = [BigNum]::PowTen(-$wrkRes)

		while ($true) {
			$term *= $constMinusOne * $x2
			$term /= [BigNum]::new( ($constTwo*$n) * ($constTwo*$n + $constOne) )
			$n += 1
			if ($term.Abs() -lt $target ) {
				break
			}
			$sum += $term
		}

		return $sum.CloneWithNewResolution($targetRes)
	}

	# Cos: Cosine Function.
	static [BigNum] Cos([BigNum] $val) {
		
		# Cos is defined on R

		[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		[BigNum] $constOne = ([BigNum]"1").CloneWithNewResolution($wrkRes)
		[BigNum] $constMinusOne = ([BigNum]"-1").CloneWithNewResolution($wrkRes)
		[BigNum] $constTwo = ([BigNum]"2").CloneWithNewResolution($wrkRes)
		[BigNum] $constTau = [BigNum]::Tau($wrkRes)

		# Preliminary: reduce x to [-π, π] range
		[BigNum] $k = ($val / $constTau).Round(0)
		$x = $val - $k * $constTau
		$term = $constOne.Clone()

		[BigNum] $sum = $term.Clone()
		[BigNum] $x2 = $x * $x
		[System.Numerics.BigInteger] $n = 1

		[BigNum] $target = [BigNum]::PowTen(-$wrkRes)

		while ($true) {
			$term *= $constMinusOne * $x2
			$term /= [BigNum]::new( ($constTwo*$n) * ($constTwo*$n - $constOne) )
			$n += 1
			if ($term.Abs() -lt $target ) {
				break
			}
			$sum += $term
		}

		return $sum.CloneWithNewResolution($targetRes)
	}

	# Tan: Tangent Function.
	static [BigNum] Tan([BigNum] $val) {

		# Tan is defined on R \ {Pi/2 + kPi, k in Z} (Cos != 0)

		[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		[BigNum] $sinX = [BigNum]::Sin($val.CloneWithNewResolution($wrkRes))
		[BigNum] $cosX = [BigNum]::Cos($val.CloneWithNewResolution($wrkRes))

		# if (cosX.Abs() -lt [BigNum]::PowTen(-x.maxDecimalResolution + 2)) {
		# 	throw "Tan(x) undefined: Cos(x) too close to zero."
		# }

		if($cosX.IsNull()) {
			throw "Tan(x) undefined: Cos(x) is null."
		}


		return ($sinX / $cosX).CloneWithNewResolution($targetRes)
	}

	# Csc: Cosecant Function.
	static [BigNum] Csc([BigNum] $val) {

		# Csc is defined on R \ {kPi, k in Z} (Sin != 0)

		[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		[BigNum] $constOne = ([BigNum]"1").CloneWithNewResolution($wrkRes)
		[BigNum] $sinVal = [BigNum]::Sin($val.CloneWithNewResolution($wrkRes))

		if($sinVal.IsNull()) {
			throw "Csc(x) undefined: Sin(x) is null."
		}

		return ($constOne / $sinVal).CloneWithNewResolution($targetRes)
	}

	# Sec: Secant Function.
	static [BigNum] Sec([BigNum] $val) {

		# Sec is defined on R \ {Pi/2 + kPi, k in Z} (Cos != 0)

		[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		[BigNum] $constOne = ([BigNum]"1").CloneWithNewResolution($wrkRes)
		[BigNum] $cosVal = [BigNum]::Cos($val.CloneWithNewResolution($wrkRes))

		if($cosVal.IsNull()) {
			throw "Sec(x) undefined: Cos(x) is null."
		}

		return ($constOne / $cosVal).CloneWithNewResolution($targetRes)
	}

	# Cot: Cotangent Function.
	static [BigNum] Cot([BigNum] $val) {

		# Cot is defined on R \ {kPi, k in Z} (Sin != 0)

		[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		[BigNum] $constOne = ([BigNum]"1").CloneWithNewResolution($wrkRes)
		[BigNum] $sinVal = [BigNum]::Cos($val.CloneWithNewResolution($wrkRes))

		if($sinVal.IsNull()) {
			throw "Cot(x) undefined: Sin(x) is null."
		}

		[BigNum] $tanVal = [BigNum]::Tan($val.CloneWithNewResolution($wrkRes))

		if($tanVal.IsNull()) {
			throw "Cot(x) undefined: Tan(x) is null."
		}

		return ($constOne / $tanVal).CloneWithNewResolution($targetRes)
	}

	# Arcsin: Inverse Sine Function.
	static [BigNum] Arcsin([BigNum] $val) {

		# Arcsin is defined on [−1, 1]

		[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
		[System.Numerics.BigInteger] $wrkRes = $targetRes + 10

		[BigNum] $absVal = $val.Abs().CloneWithNewResolution($wrkRes)
		[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)
		[BigNum] $constOne = ([BigNum]"1").CloneWithNewResolution($wrkRes)
		[BigNum] $constTwo = ([BigNum]"2").CloneWithNewResolution($wrkRes)
		[BigNum] $piOver2 = [BigNum]::Pi($wrkRes) / $constTwo

		if ($absVal -gt $constOne) {
			throw "Arcsin undefined for |x| > 1"
		}

		if ($absVal -eq $constOne) {
			return ($val.IsStrictlyNegative() ? -$piOver2 : $piOver2).Truncate($targetRes)
		}

		[BigNum] $oneMinusXSquared = $constOne - ($tmpVal * $tmpVal)
		[BigNum] $sqrtTerm = [BigNum]::Sqrt($oneMinusXSquared)
		[BigNum] $ratio = $tmpVal / $sqrtTerm
		[BigNum] $result = [BigNum]::Arctan($ratio)

		return $result.CloneWithNewResolution($targetRes)
	}

	# Arccos: Inverse Cosine Function.
	static [BigNum] Arccos([BigNum] $val) {

		# Arccos is defined on [−1, 1]

		[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
		[System.Numerics.BigInteger] $wrkRes = $targetRes + 10

		[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)
		[BigNum] $absVal = $tmpVal.Abs().CloneWithNewResolution($wrkRes)
		[BigNum] $constOne = ([BigNum]"1").CloneWithNewResolution($wrkRes)

		if ($absVal -gt $constOne) {
			throw "Arccos undefined for |x| > 1"
		}

		[BigNum] $piOver2 = [BigNum]::Pi($wrkRes) / ([BigNum]"2").CloneWithNewResolution($wrkRes)
		[BigNum] $arcsin = [BigNum]::Arcsin($tmpVal.CloneWithNewResolution($wrkRes))
		[BigNum] $result = $piOver2 - $arcsin

		return $result.CloneWithNewResolution($targetRes)
	}

	# Arctan: Inverse Tangent Function.
	static [BigNum] Arctan([BigNum] $val) {

		# Arctan is defined on R

		[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
		[System.Numerics.BigInteger] $wrkRes = $targetRes + 10

		[BigNum] $absVal = $val.Abs().CloneWithNewResolution($wrkRes)
		[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)
		[BigNum] $threshold = ([BigNum]"0.9").CloneWithNewResolution($wrkRes)
		[BigNum] $constOne = ([BigNum]"1").CloneWithNewResolution($wrkRes)
		[BigNum] $constMinusOne = ([BigNum]"-1").CloneWithNewResolution($wrkRes)
		[BigNum] $constTwo = ([BigNum]"2").CloneWithNewResolution($wrkRes)
		[BigNum] $piOver2 = [BigNum]::Pi($wrkRes) / $constTwo

		# For |x| > 1
		if ($absVal -gt $constOne) {
			# Reduce large x: atan(x) = pi/2 * sign(x) - atan(1/x)
			[System.Numerics.BigInteger] $wrkReccuring = $wrkRes + 10
			[BigNum] $invX = $constOne.CloneWithNewResolution($wrkReccuring) / $absVal.CloneWithNewResolution($wrkReccuring)
			[BigNum] $atanInv = [BigNum]::Arctan($invX)
			$result = $piOver2.CloneWithNewResolution($wrkReccuring) - $atanInv
			if ($tmpVal.IsStrictlyNegative()) { $result = -$result }
			return $result.Truncate($targetRes)
		}

		# For x near 1, with x < 1
		if ($absVal -gt $threshold) {
			[BigNum] $newX = $tmpVal / ($constOne + [BigNum]::Sqrt($constOne + [BigNum]::Pow($tmpVal,$constTwo)))
			return ($constTwo * [BigNum]::Arctan($newX)).Truncate($targetRes)
		}

		# Taylor series for |x| <= 1
		[BigNum] $term = $tmpVal.Clone()
		[BigNum] $sum = $tmpVal.Clone()
		[BigNum] $tmpValSquare = $tmpVal * $tmpVal
		[BigNum] $target = [BigNum]::PowTen(-$wrkRes)
		[BigNum] $currentSign = $constMinusOne
		[System.Numerics.BigInteger] $n = 1

		while ($term.Abs() -gt $target) {
			$n += 2
			$term = ( $term * $tmpValSquare * ($n - 2) ) / $n
			$sum += $currentSign * $term
			$currentSign = -$currentSign
		}

		return $sum.CloneWithNewResolution($targetRes)
	}

	# Atan2: Two-Argument Inverse Tangent Function. Returns a quadrant-aware signed angle.
	static [BigNum] Atan2([BigNum] $y, [BigNum] $x) {

		# Atan2 is defined on R x R

		[System.Numerics.BigInteger] $targetRes = ([BigNum]::Max($y.maxDecimalResolution, $x.maxDecimalResolution)).Int()
		[System.Numerics.BigInteger] $wrkRes = $targetRes + 10

		[BigNum] $constZero = ([BigNum]"0").CloneWithNewResolution($wrkRes)
		[BigNum] $constPi = [BigNum]::Pi($wrkRes)
		[BigNum] $constPiOverTwo = $constPi / ([BigNum]"2").CloneWithNewResolution($wrkRes)

		if ($x.IsNull()) {
			if ($y.IsNull()) { return $constZero.CloneWithNewResolution($targetRes) }
			return ($y.IsStrictlyPositive() ? $constPiOverTwo : -$constPiOverTwo).CloneWithNewResolution($targetRes)
		}

		[BigNum] $arctan = [BigNum]::Arctan(($y.CloneWithNewResolution($wrkRes) / $x.CloneWithNewResolution($wrkRes)))

		if ($x.IsStrictlyPositive()) {
			return $arctan.CloneWithNewResolution($targetRes)
		}
		elseif ($y.IsStrictlyPositive()) {
			return ($arctan + $constPi).CloneWithNewResolution($targetRes)
		}
		else {
			return ($arctan - $constPi).CloneWithNewResolution($targetRes)
		}
	}

	# Arccsc: Inverse Cosecant Function.
	static [BigNum] Arccsc([BigNum] $val) {

		# Arccsc is defined on ]-Inf, −1] U [1, +Inf[

		[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)
		[BigNum] $absVal = $tmpVal.Abs().CloneWithNewResolution($wrkRes)

		if ($absVal -lt 1) {
			throw "Error in [BigNum]::Arccsc : magnitude of val must be strictly greater than 1"
		}

		[BigNum] $constOne = ([BigNum]"1").CloneWithNewResolution($wrkRes)
		[BigNum] $arccscVal = [BigNum]::Arcsin($constOne / $tmpVal)

		return $arccscVal.CloneWithNewResolution($targetRes)
	}

	# Arcsec: Inverse Secant Function.
	static [BigNum] Arcsec([BigNum] $val) {

		# Arcsec is defined on ]-Inf, −1] U [1, +Inf[

		[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)
		[BigNum] $absVal = $tmpVal.Abs().CloneWithNewResolution($wrkRes)

		if ($absVal -lt 1) {
			throw "Error in [BigNum]::Arcsec : magnitude of val must be strictly greater than 1"
		}

		[BigNum] $constOne = ([BigNum]"1").CloneWithNewResolution($wrkRes)
		[BigNum] $arcsecVal = [BigNum]::Arccos($constOne / $tmpVal)

		return $arcsecVal.CloneWithNewResolution($targetRes)
	}

	# Arccot: Inverse Cotangent Function.
	static [BigNum] Arccot([BigNum] $val) {

		# Arccot is defined on R

		[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		[BigNum] $constTwo = ([BigNum]"2").CloneWithNewResolution($wrkRes)
		[BigNum] $constPi = [BigNum]::Pi($wrkRes)
		[BigNum] $newVal = $val.CloneWithNewResolution($wrkRes)

		[BigNum] $arccotVal = ($constPi/$constTwo) - [BigNum]::Arctan($newVal)

		return $arccotVal.CloneWithNewResolution($targetRes)
	}

	#endregion static Trigonometry Methods



	#region static Hyperbolic Trigonometry Methods

	# Sinh: Hyperbolic Sine Function.
	static [BigNum] Sinh([BigNum] $val) {

		# Sinh is defined on R

		[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)
		[BigNum] $expPlus  = [BigNum]::Exp($tmpVal)
		[BigNum] $expMinus = [BigNum]::Exp(-$tmpVal)
		[BigNum] $half     = [BigNum]::new("0.5").CloneWithNewResolution($wrkRes)

		[BigNum] $sinhVal = ($expPlus - $expMinus) * $half

		return $sinhVal.CloneWithNewResolution($targetRes)
	}

	# Cosh: Hyperbolic Cosine Function.
	static [BigNum] Cosh([BigNum] $val) {

		# Cosh is defined on R

		[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)
		[BigNum] $expPlus  = [BigNum]::Exp($tmpVal)
		[BigNum] $expMinus = [BigNum]::Exp(-$tmpVal)
		[BigNum] $half     = [BigNum]::new("0.5").CloneWithNewResolution($wrkRes)

		[BigNum] $coshVal = ($expPlus + $expMinus) * $half

		return $coshVal.CloneWithNewResolution($targetRes)
	}

	# Tanh: Hyperbolic Tangent Function.
	static [BigNum] Tanh([BigNum] $val) {

		# Tanh is defined on R

		[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)
		[BigNum] $num  = [BigNum]::Sinh($tmpVal)
		[BigNum] $den = [BigNum]::Cosh($tmpVal)
		[BigNum] $tanhVal = ($num / $den)

		return $tanhVal.CloneWithNewResolution($targetRes)
	}

	# Csch: Hyperbolic Cosecant Function.
	static [BigNum] Csch([BigNum] $val) {

		# Csch is defined on R*

		if ($val.IsNull()) {
			throw "Error in [BigNum]::Csch : val must not be null"
		}

		[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)
		[BigNum] $num  = ([BigNum]1).CloneWithNewResolution($wrkRes)
		[BigNum] $den = [BigNum]::Sinh($tmpVal)
		[BigNum] $cschVal = ($num / $den)

		return $cschVal.CloneWithNewResolution($targetRes)
	}

	# Sech: Hyperbolic Secant Function.
	static [BigNum] Sech([BigNum] $val) {

		# Sech is defined on R

		[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)
		[BigNum] $num  = ([BigNum]1).CloneWithNewResolution($wrkRes)
		[BigNum] $den = [BigNum]::Cosh($tmpVal)
		[BigNum] $sechVal = ($num / $den)

		return $sechVal.CloneWithNewResolution($targetRes)
	}

	# Coth: Hyperbolic Cotangent Function.
	static [BigNum] Coth([BigNum] $val) {

		# Coth is defined on R*

		if ($val.IsNull()) {
			throw "Error in [BigNum]::Coth : val must not be null"
		}

		[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)
		[BigNum] $num  = [BigNum]::Cosh($tmpVal)
		[BigNum] $den = [BigNum]::Sinh($tmpVal)
		[BigNum] $cothVal = ($num / $den)

		return $cothVal.CloneWithNewResolution($targetRes)
	}

	# Arcsinh: Inverse Hyperbolic Sine Function.
	static [BigNum] Arcsinh([BigNum] $val) {

		# Arcsinh is defined on R

		[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		[BigNum] $constOne = ([BigNum]1).CloneWithNewResolution($wrkRes)
		[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)

		[BigNum] $sqrtPart  = [BigNum]::Sqrt(($tmpVal * $tmpVal) + $constOne)
		[BigNum] $arcsinhVal = [BigNum]::Ln($tmpVal + $sqrtPart)

		return $arcsinhVal.CloneWithNewResolution($targetRes)
	}

	# Arccosh: Inverse Hyperbolic Cosine Function.
	static [BigNum] Arccosh([BigNum] $val) {

		# Arccosh is defined on [1, +Inf[

		if ($val -lt 1) {
			throw "Error in [BigNum]::Arccosh : val must be equal or greater than 1"
		}

		[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		[BigNum] $constOne = ([BigNum]1).CloneWithNewResolution($wrkRes)
		[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)

		[BigNum] $sqrtPart  = [BigNum]::Sqrt(($tmpVal * $tmpVal) - $constOne)
		[BigNum] $arccoshVal = [BigNum]::Ln($tmpVal + $sqrtPart)

		return $arccoshVal.CloneWithNewResolution($targetRes)
	}

	# Arctanh: Inverse Hyperbolic Tangent Function.
	static [BigNum] Arctanh([BigNum] $val) {

		# Arctanh is defined on ]−1, 1[

		[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5
		[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)
		[BigNum] $absVal = $tmpVal.Abs().CloneWithNewResolution($wrkRes)

		if ($absVal -ge 1) {
			throw "Error in [BigNum]::Arctanh : magnitude of val must be strictly smaller than 1"
		}

		[BigNum] $constOne = ([BigNum]1).CloneWithNewResolution($wrkRes)
		[BigNum] $constHalf = ([BigNum]"0.5").CloneWithNewResolution($wrkRes)
		[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)

		[BigNum] $arctanhVal = $constHalf * [BigNum]::Ln($($constOne + $tmpVal) / ($constOne - $tmpVal))

		return $arctanhVal.CloneWithNewResolution($targetRes)
	}

	# Arccsch: Inverse Hyperbolic Cosecant Function.
	static [BigNum] Arccsch([BigNum] $val) {

		# Arccsch is defined on R*

		if ($val.IsNull()) {
			throw "Error in [BigNum]::Arccsch : val must not be null"
		}

		[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		[BigNum] $constOne = ([BigNum]1).CloneWithNewResolution($wrkRes)
		[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)

		[BigNum] $invX = $constOne / $tmpVal
		[BigNum] $sqrtPart = [BigNum]::Sqrt(($invX * $invX) + $constOne)
		[BigNum] $arccschVal = [BigNum]::Ln($invX + $sqrtPart)

		return $arccschVal.CloneWithNewResolution($targetRes)
	}

	# Arcsech: Inverse Hyperbolic Secant Function.
	static [BigNum] Arcsech([BigNum] $val) {

		# Arcsech is defined on ]0, 1]

		if (($val -le 0) -or ($val -gt 1)) {
			throw "Error in [BigNum]::Arcsech : val must be greater than 0 and smaller or equal to 1"
		}

		[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		[BigNum] $constOne = ([BigNum]1).CloneWithNewResolution($wrkRes)
		[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)

		[BigNum] $invX = $constOne / $tmpVal
		[BigNum] $sqrtPart = [BigNum]::Sqrt(($invX * $invX) - $constOne)
		[BigNum] $arcsechVal = [BigNum]::Ln($invX + $sqrtPart)

		return $arcsechVal.CloneWithNewResolution($targetRes)
	}

	# Arccoth: Inverse Hyperbolic Cotangent Function.
	static [BigNum] Arccoth([BigNum] $val) {

		# Arccoth is defined on ]-Inf, −1] U [1, +Inf[

		if ($val.Abs() -le 1) {
			throw "Error in [BigNum]::Arccoth : magnitude of val must be greater than 1"
		}
		
		[System.Numerics.BigInteger] $targetRes = $val.maxDecimalResolution
		[System.Numerics.BigInteger] $wrkRes = $targetRes +5

		[BigNum] $constOne = ([BigNum]1).CloneWithNewResolution($wrkRes)
		[BigNum] $constHalf = ([BigNum]"0.5").CloneWithNewResolution($wrkRes)
		[BigNum] $tmpVal = $val.CloneWithNewResolution($wrkRes)

		[BigNum] $arccothVal = $constHalf * [BigNum]::Ln($($tmpVal + $constOne) / ($tmpVal - $constOne))

		return $arccothVal.CloneWithNewResolution($targetRes)
	}

	#endregion static Hyperbolic Trigonometry Methods



	#region instance Methods

	# Int : Return a signed BigInteger contaning the original value truncated to zero decimals.
	[System.Numerics.BigInteger] Int() {
		return [System.Numerics.BigInteger]::Parse($this.Truncate(0))
	}

	# Abs : Return a clone containing the absolute value of the original BigNum.
	[BigNum] Abs() {
		return [BigNum]::new($this.integerVal,$this.shiftVal,$false,$this.maxDecimalResolution)
	}

	# FractionalPart : Return a clone containing the Fractional Part of the original BigNum.
	[BigNum] FractionalPart() {
		$tmpval = $this.Clone()
		$tmpval -= $tmpval.Truncate(0)
		return $tmpval.Clone()
	}

	# Round : Return a clone of the original BigNum rounded to $decimals digits, using the half-up rule.
	[BigNum] Round([System.Numerics.BigInteger]$decimals){
		$alteration = 0
		# if ($this.negativeFlag) { $alteration = -1 }

		$newValStr += "" + "0" + $this.integerVal.ToString()
		[System.Numerics.BigInteger]$newVal = [System.Numerics.BigInteger]::Parse($newValStr)
		$toRound = $this.shiftVal - $decimals
		$newShift = $this.shiftVal

		if ($toRound -gt 0) {
			if ($toRound -gt ($newValStr.Length - 1)) {
				$newVal = "0"
				$newShift = "0"
			}else{

				
				if([int]::Parse($newValStr[-$toRound]) -ge 5){
					$alteration = 1
				}

				$newValStr = $newValStr.Substring(0,$newValStr.Length - $toRound)
				$newVal = [System.Numerics.BigInteger]::Parse($newValStr)
				
				$newVal += $alteration
				$newShift = $decimals
			}
			
		}

		return [BigNum]::new($newVal,$newShift,$this.negativeFlag,$this.maxDecimalResolution)
	}

	# Ceiling : Return a clone of the original BigNum rounded to $decimals digits, using the always up rule.
	[BigNum] Ceiling([System.Numerics.BigInteger]$decimals){
		$alteration = 1
		if ($this.negativeFlag) {
			$alteration = 0
		}

		$newValStr += "" + "0" + $this.integerVal.ToString()
		[System.Numerics.BigInteger]$newVal = [System.Numerics.BigInteger]::Parse($newValStr)
		$toRound = $this.shiftVal - $decimals
		$newShift = $this.shiftVal
		$newSign = $this.negativeFlag

		if ($toRound -gt 0) {
			if ($toRound -gt ($newValStr.Length - 1)) {
				$newVal = "0"
				if (($this.integerVal -ne 0) -and (-not $this.negativeFlag)) {
					$newVal = [BigNum]::PowTenPositive($toRound - $this.shiftVal)
				}
				$newSign = $false
				$newShift = "0"
			}else{

				$rest = $newValStr.Substring($newValStr.Length - $toRound,$toRound)
				$valRest = [System.Numerics.BigInteger]::Parse($rest)
				if ($valRest -eq 0) {
					$alteration = 0
				}

				$newValStr = $newValStr.Substring(0,$newValStr.Length - $toRound)
				$newVal = [System.Numerics.BigInteger]::Parse($newValStr)
				if ($newVal -eq 0) {
					$newSign = $false
				}
				
				$newVal += $alteration
				$newShift = $decimals
			}
			
		}

		return [BigNum]::new($newVal,$newShift,$newSign,$this.maxDecimalResolution)
	}

	# Floor : Return a clone of the original BigNum rounded to $decimals digits, using the always down rule.
	[BigNum] Floor([System.Numerics.BigInteger]$decimals){
		$alteration = 0
		if ($this.negativeFlag) {
			$alteration = 1
		}

		$newValStr += "" + "0" + $this.integerVal.ToString()
		[System.Numerics.BigInteger]$newVal = [System.Numerics.BigInteger]::Parse($newValStr)
		$toRound = $this.shiftVal - $decimals
		$newShift = $this.shiftVal
		$newSign = $this.negativeFlag

		if ($toRound -gt 0) {
			if ($toRound -gt ($newValStr.Length - 1)) {
				$newVal = "0"
				$newSign = $false
				if (($this.integerVal -ne 0) -and ($this.negativeFlag)) {
					$newVal = [BigNum]::PowTenPositive($toRound - $this.shiftVal)
					$newSign = $true
				}
				$newShift = "0"
			}else{

				$rest = $newValStr.Substring($newValStr.Length - $toRound,$toRound)
				$valRest = [System.Numerics.BigInteger]::Parse($rest)
				if ($valRest -eq 0) {
					$alteration = 0
				}

				$newValStr = $newValStr.Substring(0,$newValStr.Length - $toRound)
				$newVal = [System.Numerics.BigInteger]::Parse($newValStr)
				if (($newVal -eq 0) -and ($alteration -eq 0)) {
					$newSign = $false
				}
				
				$newVal += $alteration
				$newShift = $decimals
			}
		}

		return [BigNum]::new($newVal,$newShift,$newSign,$this.maxDecimalResolution)
	}

	# RoundAwayFromZero : Return a clone of the original BigNum rounded to $decimals digits, using the always Away-From-Zero rule.
	[BigNum] RoundAwayFromZero([System.Numerics.BigInteger]$decimals){
		$alteration = 1

		$newValStr += "" + "0" + $this.integerVal.ToString()
		[System.Numerics.BigInteger]$newVal = [System.Numerics.BigInteger]::Parse($newValStr)
		$toRound = $this.shiftVal - $decimals
		$newShift = $this.shiftVal
		$newSign = $this.negativeFlag

		if ($toRound -gt 0) {
			if ($toRound -gt ($newValStr.Length - 1)) {
				$newVal = "0"
				if (($this.integerVal -ne 0)) {
					$newVal = [BigNum]::PowTenPositive($toRound - $this.shiftVal)
				}
				$newShift = "0"
			}else{

				$rest = $newValStr.Substring($newValStr.Length - $toRound,$toRound)
				$valRest = [System.Numerics.BigInteger]::Parse($rest)
				if ($valRest -eq 0) {
					$alteration = 0
				}

				$newValStr = $newValStr.Substring(0,$newValStr.Length - $toRound)
				$newVal = [System.Numerics.BigInteger]::Parse($newValStr)
				if (($newVal -eq 0) -and ($alteration -eq 0)) {
					$newSign = $false
				}
				
				$newVal += $alteration
				$newShift = $decimals
			}
		}

		return [BigNum]::new($newVal,$newShift,$newSign,$this.maxDecimalResolution)
	}

	# Truncate : Return a clone of the original BigNum truncated to $decimals digits. This function doest not round, just cut.
	[BigNum] Truncate([System.Numerics.BigInteger]$decimals) {
		$tmpVal = [System.Numerics.BigInteger]::Parse($this.integerVal)
		[string]$tmpString = $tmpVal.ToString()
		$tmpShift = [System.Numerics.BigInteger]::Parse($this.shiftVal)
		$tmpSign = $this.negativeFlag
		$tmpResolution = [System.Numerics.BigInteger]::Parse($this.maxDecimalResolution)

		if($tmpShift -gt $decimals) {
			[System.Numerics.BigInteger]$newEnd = [System.Numerics.BigInteger]::Parse(0)
			$newEnd += $tmpString.Length - $tmpShift + $decimals

			if ($newEnd -gt 0) {
				$tmpVal = [System.Numerics.BigInteger]::Parse($tmpString.Substring(0,$newEnd))

				if ($decimals -ge 0) {
					$tmpShift = [System.Numerics.BigInteger]::Parse($decimals)
				}else{
					$tmpShift = [System.Numerics.BigInteger]::Parse(0)
					$tmpVal *= [BigNum]::PowTenPositive(-$decimals)
				}
			}else{
				$tmpShift = [System.Numerics.BigInteger]::Parse(0)
				$tmpVal = [System.Numerics.BigInteger]::Parse(0)
				$tmpSign = $false
			}
		}

		return [BigNum]::new($tmpVal,$tmpShift,$tmpSign,$tmpResolution)
	}

	#endregion instance Methods



	#region Math Constants

	# Pi : Return the 1000 first digits of Pi.
	static [BigNum] Pi() {
		return [BigNum]::new("3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679821480865132823066470938446095505822317253594081284811174502841027019385211055596446229489549303819644288109756659334461284756482337867831652712019091456485669234603486104543266482133936072602491412737245870066063155881748815209209628292540917153643678925903600113305305488204665213841469519415116094330572703657595919530921861173819326117931051185480744623799627495673518857527248912279381830119491298336733624406566430860213949463952247371907021798609437027705392171762931767523846748184676694051320005681271452635608277857713427577896091736371787214684409012249534301465495853710507922796892589235420199561121290219608640344181598136297747713099605187072113499999983729780499510597317328160963185950244594553469083026425223082533446850352619311881710100031378387528865875332083814206171776691473035982534904287554687311595628638823537875937519577818577805321712268066130019278766111959092164201989").CloneWithAdjustedResolution()
	}

	# Pi : (BigInteger) Return the $resolution first digits of Pi.
	static [BigNum] Pi([System.Numerics.BigInteger] $resolution) {
		if($resolution -lt 0){
			throw "Resolution for Pi must be a null or positive integer"
		}

		if (-not [BigNum]::cachedPi) {
        	[BigNum]::cachedPi = [BigNum]::Pi()
    	}

		if (-not [BigNum]::cachedTau) {
        	[BigNum]::cachedTau = [BigNum]::Tau()
    	}

		if ($resolution -le 1000) {
			return [BigNum]::Pi().Truncate($resolution).CloneWithNewResolution($resolution)
		}

		if ($resolution -le [BigNum]::cachedPi.GetMaxDecimalResolution()) {
			return [BigNum]::cachedPi.Truncate($resolution).CloneWithNewResolution($resolution)
		}

		$tmpResolution = $resolution + 5

		$a = [BigNum]::new(1).CloneWithNewResolution($tmpResolution)
		$b = [BigNum]::new(1).CloneWithNewResolution($tmpResolution) / [BigNum]::Sqrt(([BigNum]2).CloneWithNewResolution($tmpResolution))
		$p = [BigNum]::new(1).CloneWithNewResolution($tmpResolution)
		$t = [BigNum]::new(0.25).CloneWithNewResolution($tmpResolution)

		$constTwo = [BigNum]::new(2).CloneWithNewResolution($tmpResolution)
		$constFour = [BigNum]::new(4).CloneWithNewResolution($tmpResolution)
		$referenceDiff = [BigNum]::PowTen(-$resolution).CloneWithNewResolution($tmpResolution)

		$tmpPi = [BigNum]::new(3).CloneWithNewResolution($tmpResolution)
		$diff = [BigNum]::new("0.14").CloneWithNewResolution($tmpResolution)

		do {
			$tmpPi_old = $tmpPi

			$a_next = ($a + $b) / $constTwo
			$b_next = [BigNum]::Sqrt(($a * $b).CloneWithNewResolution($tmpResolution))
			$p_next = $constTwo * $p
			$t_next = $t - ($p * [BigNum]::Pow($a_next - $a,2))

			$a = $a_next
			$b = $b_next
			$p = $p_next
			$t = $t_next

			$tmpPi = (($a + $b) * ($a + $b)) / ($constFour * $t)
			$diff = ($tmpPi - $tmpPi_old).Abs()
		} while ($diff -gt $referenceDiff)

		[BigNum]::cachedPi = [BigNum]::new([BigNum]$tmpPi).Truncate($resolution).CloneWithNewResolution($resolution)
		[BigNum]::cachedTau = ([BigNum]::cachedPi * 2).Truncate($resolution).CloneWithNewResolution($resolution)

		return [BigNum]::cachedPi.Clone()
	}

	# ClearCachedPi : Clear the cached digits of Pi.
	static [void] ClearCachedPi() {
    	[BigNum]::cachedPi = $null
	}

	# Tau : Return the 1000 first digits of Tau (2*Pi).
	static [BigNum] Tau() {
		return [BigNum]::new("6.2831853071795864769252867665590057683943387987502116419498891846156328125724179972560696506842341359642961730265646132941876892191011644634507188162569622349005682054038770422111192892458979098607639288576219513318668922569512964675735663305424038182912971338469206972209086532964267872145204982825474491740132126311763497630418419256585081834307287357851807200226610610976409330427682939038830232188661145407315191839061843722347638652235862102370961489247599254991347037715054497824558763660238982596673467248813132861720427898927904494743814043597218874055410784343525863535047693496369353388102640011362542905271216555715426855155792183472743574429368818024499068602930991707421015845593785178470840399122242580439217280688363196272595495426199210374144226999999967459560999021194634656321926371900489189106938166052850446165066893700705238623763420200062756775057731750664167628412343553382946071965069808575109374623191257277647075751875039155637155610643424536132260038557532223918184328403978").CloneWithAdjustedResolution()
	}

	# Tau : (BigInteger) Return the $resolution first digits of Tau (2*Pi).
	static [BigNum] Tau([System.Numerics.BigInteger] $resolution) {
		if($resolution -lt 0){
			throw "Resolution for Tau must be a null or positive integer"
		}

		if (-not [BigNum]::cachedTau) {
        	[BigNum]::cachedTau = [BigNum]::Tau()
    	}

		if ($resolution -le 1000) {
			return [BigNum]::Tau().Truncate($resolution).CloneWithNewResolution($resolution)
		}

		if ($resolution -le [BigNum]::cachedTau.GetMaxDecimalResolution()) {
			return [BigNum]::cachedTau.Truncate($resolution).CloneWithNewResolution($resolution)
		}

		[BigNum]::Pi($resolution)

		return [BigNum]::cachedTau.Clone()
	}

	# ClearCachedTau : Clear the cached digits of Tau (2*Pi).
	static [void] ClearCachedTau() {
    	[BigNum]::cachedTau = $null
	}

	# e : Return the 1000 first digits of e.
	static [BigNum] e() {
		# 1000 decimal long
		return [BigNum]::new("2.7182818284590452353602874713526624977572470936999595749669676277240766303535475945713821785251664274274663919320030599218174135966290435729003342952605956307381323286279434907632338298807531952510190115738341879307021540891499348841675092447614606680822648001684774118537423454424371075390777449920695517027618386062613313845830007520449338265602976067371132007093287091274437470472306969772093101416928368190255151086574637721112523897844250569536967707854499699679468644549059879316368892300987931277361782154249992295763514822082698951936680331825288693984964651058209392398294887933203625094431173012381970684161403970198376793206832823764648042953118023287825098194558153017567173613320698112509961818815930416903515988885193458072738667385894228792284998920868058257492796104841984443634632449684875602336248270419786232090021609902353043699418491463140934317381436405462531520961836908887070167683964243781405927145635490613031072085103837505101157477041718986106873969655212671546889570350354").CloneWithAdjustedResolution()
	}

	# e : (BigInteger) Return the $resolution first digits of e.
	static [BigNum] e([System.Numerics.BigInteger] $resolution) {
		if($resolution -lt 0){
			throw "Resolution for e must be a null or positive integer"
		}

		if (-not [BigNum]::cachedE) {
        	[BigNum]::cachedE = [BigNum]::e()
    	}

		if ($resolution -le 1000) {
			return [BigNum]::e().Truncate($resolution).CloneWithNewResolution($resolution)
		}

		if ($resolution -le [BigNum]::cachedE.GetMaxDecimalResolution()) {
			return [BigNum]::cachedE.Truncate($resolution).CloneWithNewResolution($resolution)
		}

		$tmpResolution = $resolution + 100
		[BigNum] $result = [BigNum]::new(1).CloneWithNewResolution($tmpResolution)
		[BigNum] $factorial = [BigNum]::new(1).CloneWithNewResolution($tmpResolution)

		for ([System.Numerics.BigInteger]$n = 1; $n -le $tmpResolution; $n += 1) {
			$factorial *= [BigNum]::new($n)
			$result += [BigNum]::new(1) / $factorial
		}

		[BigNum]::cachedE = [BigNum]::new($result).Truncate($resolution).CloneWithNewResolution($resolution)

		return [BigNum]::cachedE.Clone()
	}

	# ClearCachedE : Clear the cached digits of e.
	static [void] ClearCachedE() {
    	[BigNum]::cachedE = $null
	}

	# Phi : Return the 1000 first digits of Phi.
	static [BigNum] Phi() {
		return [BigNum]::new("1.6180339887498948482045868343656381177203091798057628621354486227052604628189024497072072041893911374847540880753868917521266338622235369317931800607667263544333890865959395829056383226613199282902678806752087668925017116962070322210432162695486262963136144381497587012203408058879544547492461856953648644492410443207713449470495658467885098743394422125448770664780915884607499887124007652170575179788341662562494075890697040002812104276217711177780531531714101170466659914669798731761356006708748071013179523689427521948435305678300228785699782977834784587822891109762500302696156170025046433824377648610283831268330372429267526311653392473167111211588186385133162038400522216579128667529465490681131715993432359734949850904094762132229810172610705961164562990981629055520852479035240602017279974717534277759277862561943208275051312181562855122248093947123414517022373580577278616008688382952304592647878017889921990270776903895321968198615143780314997411069260886742962267575605231727775203536139362").CloneWithAdjustedResolution()
	}

	# Phi : (BigInteger) Return the $resolution first digits of Phi.
	static [BigNum] Phi([System.Numerics.BigInteger] $resolution) {
		if($resolution -lt 0){
			throw "Resolution for Phi must be a null or positive integer"
		}

		if (-not [BigNum]::cachedPhi) {
        	[BigNum]::cachedPhi = [BigNum]::Phi()
    	}

		if ($resolution -le 1000) {
			return [BigNum]::Phi().Truncate($resolution).CloneWithNewResolution($resolution)
		}

		if ($resolution -le [BigNum]::cachedPhi.GetMaxDecimalResolution()) {
			return [BigNum]::cachedPhi.Truncate($resolution).CloneWithNewResolution($resolution)
		}

		$tmpResolution = $resolution + 100

		# First, define a few high-res constants
		[BigNum] $constOne = [BigNum]::new(1).CloneWithNewResolution($tmpResolution)
		[BigNum] $constTwo = [BigNum]::new(2).CloneWithNewResolution($tmpResolution)
		[BigNum] $constFive = [BigNum]::new(5).CloneWithNewResolution($tmpResolution)

		# Then, get the square root of 5
		[BigNum] $constSqrt5 = [BigNum]::Sqrt($constFive)
		
		# Then calculate (1 + sqrt(5)) / 2
		[BigNum] $tmpPhi = ($constOne + $constSqrt5) / $constTwo
		
		# Store at the new resolution
		[BigNum]::cachedPhi = $tmpPhi.Clone().Truncate($resolution).CloneWithNewResolution($resolution)

		# Return the new value
		return [BigNum]::cachedPhi.Clone()
	}

	# ClearCachedPhi : Clear the cached digits of Phi.
	static [void] ClearCachedPhi() {
    	[BigNum]::cachedPhi = $null
	}

	# EnsureBernoulliNumberBUpTo : INTERNAL USE. Generates the Nth Numerator and Denominator of Bernoulli Number B.
	hidden static [void] EnsureBernoulliNumberBUpTo([System.Numerics.BigInteger] $n) {
		if ($n -lt 0) { throw "[BigNum]::EnsureBernoulliNumberBUpTo(): n must be >= 0." }

		# Find highest already cached
		[System.Numerics.BigInteger]$haveMax = -1
		foreach($k in [BigNum]::cachedBernoulliNumberB.Keys){
			if ($k -gt $haveMax) { $haveMax = $k }
		}
		if ($haveMax -ge $n) { return }

		$A = New-Object object[] ($n+1)

		for($m=0; $m -le $n; $m += 1){

			# A[m] = 1 / (m+1)
			$num = [System.Numerics.BigInteger]::One
			$den = [System.Numerics.BigInteger]($m + 1)
			$A[$m] = [pscustomobject]@{num=$num; den=$den}

			# for j = m .. 1:  A[j-1] = j*(A[j-1] - A[j])
			for($j=$m; $j -ge 1; $j--){

				$a1 = $A[$j-1]
				$a2 = $A[$j]

				# diff = A[j-1] - A[j]
				$n1 = [System.Numerics.BigInteger]$a1.num
				$d1 = [System.Numerics.BigInteger]$a1.den
				$n2 = [System.Numerics.BigInteger]$a2.num
				$d2 = [System.Numerics.BigInteger]$a2.den

				# diffNum/Den = n1/d1 - n2/d2 = (n1*d2 - n2*d1) / (d1*d2)
				$diffNum = $n1 * $d2 - $n2 * $d1
				$diffDen = $d1 * $d2

				# multiply by j
				$diffNum *= [System.Numerics.BigInteger]$j

				# reduce
				$absDiff = [System.Numerics.BigInteger]::Abs($diffNum)
				$g = [System.Numerics.BigInteger]::GreatestCommonDivisor($absDiff,$diffDen)
				if ($g -gt [System.Numerics.BigInteger]::One) {
					$diffNum /= $g
					$diffDen /= $g
				}

				$A[$j-1] = [pscustomobject]@{num=$diffNum; den=$diffDen}
			}

			# After inner loop, A[0] holds B_m. Cache it.
			if (-not [BigNum]::cachedBernoulliNumberB.ContainsKey($m)) {
				[BigNum]::cachedBernoulliNumberB[$m] = $A[0]
			} else {
				# overwrite w/ recomputed canonical form (reduced)
				[BigNum]::cachedBernoulliNumberB[$m] = $A[0]
			}
    	}
	}

	# BernoulliNumberB : Generates the Nth Bernoulli Number at $res resolution. Uses Euler–Maclaurin convention: B1 = -1/2; B_odd>1 = 0.
	static [BigNum] BernoulliNumberB([int] $n, [System.Numerics.BigInteger] $res) {

		if ($n -lt 0) {
			throw "[BigNum]::BernoulliNumberB(): n must be >= 0."
		}

		[BigNum] $result = [BigNum]::new(0).CloneWithNewResolution($res)

		switch ($n) {
			0 {
				return [BigNum]::new(1).CloneWithNewResolution($res)
			}
			1 {
				# B1 = -1/2 in Euler–Maclaurin
				return ([BigNum]::new(-1).CloneWithNewResolution($res) /
						[BigNum]::new(2).CloneWithNewResolution($res)).CloneWithNewResolution($res)
			}
			default {
				# B_{odd>1} = 0
				if ( ($n % 2) -eq 1 ) {
					return [BigNum]::new(0).CloneWithNewResolution($res)
				}
				# even n >= 2: compute / fetch from cache
				[BigNum]::EnsureBernoulliNumberBUpTo($n)
				$entry = [BigNum]::cachedBernoulliNumberB[$n]
				[BigNum] $result = ([BigNum]::new([System.Numerics.BigInteger]$entry.num).CloneWithNewResolution($res) / [BigNum]::new([System.Numerics.BigInteger]$entry.den).CloneWithNewResolution($res)).CloneWithNewResolution($res)
			}
		}

		return $result
	}

	# ClearCachedBernoulliNumberB : Clear the cached values of the Bernoulli Number B
	static [void] ClearCachedBernoulliNumberB() {
    	[BigNum]::cachedBernoulliNumberB = @{}
	}

	# HarmonicSeriesHn : Returns the value of the Harmonic Series Hn at rank $N at $res resolution.
	static [BigNum] HarmonicSeriesHn([System.Numerics.BigInteger] $N,[System.Numerics.BigInteger] $res){
		if ($N -lt 0) {
			throw "[BigNum]::HarmonicSeriesHn() error: N must be >= 0."
		}

		# H_0 = 0
		if ($N -eq 0) {
			return [BigNum]::new(0).CloneWithNewResolution($res)
		}

		$resolution = $res +5

		# Reusable Consts at target working precision
		[BigNum]$constZero = [BigNum]::new(0).CloneWithNewResolution($resolution)
		[BigNum]$constOne = [BigNum]::new(1).CloneWithNewResolution($resolution)

		# Running sum
    	[BigNum]$sum = $constZero.Clone()


		# Optional compensation (Neumaier). Comment out if not needed.
    	[BigNum]$csum = $constZero.Clone()

		# Tunable block size. Larger reduces truncation overhead; smaller reduces
		# intermediate growth. 1024 is a decent compromise for testing.
		[System.Numerics.BigInteger]$blockSize = 1024


		# We'll step downward in outer chunks to interleave truncation.
		[System.Numerics.BigInteger]$k = $N
		while ($k -gt 0) {

			# compute start of this block (inclusive)
			[System.Numerics.BigInteger]$blockStart = ($k -ge $blockSize) ? ($k - $blockSize + 1) : 1

			# local block accumulator
			[BigNum]$blk = $constZero.Clone()

			for([System.Numerics.BigInteger]$i=$k; $i -ge $blockStart; $i-=1){
				# 1 / i
				[BigNum]$term = $constOne / [BigNum]::new($i).CloneWithNewResolution($resolution)
				# simple add; we *could* do compensated add but inside block cost dominates division anyway
				$blk += $term
			}

			# add block to global sum w/ Neumaier compensation (optional)
			# Neumaier: t = sum + blk; if |sum| >= |blk| then c += (sum - t) + blk else c += (blk - t) + sum
			$t = $sum + $blk
			if ($sum.Abs() -ge $blk.Abs()) {
				$csum += ($sum - $t) + $blk
			} else {
				$csum += ($blk - $t) + $sum
			}
			$sum = $t

			# Periodic truncation to keep representation bounded
			$sum  = $sum.Truncate($resolution).CloneWithNewResolution($resolution)
			$csum = $csum.Truncate($resolution).CloneWithNewResolution($resolution)

			# next chunk
			$k = $blockStart - 1
		}
		# Final compensated result
		$sum += $csum
		return $sum.Truncate($res).CloneWithNewResolution($res)
	}

	# SpougeCoefficient: Spouge Coefficient generator
	static [BigNum] SpougeCoefficient([System.Numerics.BigInteger] $k, [System.Numerics.BigInteger] $a, [System.Numerics.BigInteger] $resolution) {
		if ($a -lt 3) {
			throw "error in [BigNum]::SpougeCoefficient : a must be equal or greater than 3"
		}
		if ($k -lt 0) {
			throw "error in [BigNum]::SpougeCoefficient : k must be positive"
		}
		if($k -ge $a){
			throw "error in [BigNum]::SpougeCoefficient : k must be strictly smaller than a"
		}

		# Resolution
		$wrkRes = $resolution + 10

		# Sqrt(2*Pi)
		$ConstSqrt2Pi = ([BigNum]::Sqrt([BigNum]::Tau($wrkRes+5)))

		if ($k -eq 0) {
			return $ConstSqrt2Pi
			# return (([BigNum]::new(1).CloneWithNewResolution($resolution) / $ConstSqrt2Pi).Truncate($resolution))
			# return (([BigNum]::new(1).CloneWithNewResolution($resolution)).Truncate($resolution))
		}

		$bnA     = ([BigNum]$a).CloneWithNewResolution($wrkRes)
        $bnK     = ([BigNum]$k).CloneWithNewResolution($wrkRes)

		$powPart = [BigNum]::Pow(($bnA - $bnK), ($bnK - 0.5))
        $expPart = [BigNum]::Exp(($bnA - $bnK))
        $fact    = [BigNum]::Factorial(($k - 1)).CloneWithNewResolution($wrkRes)
        $sign    = ((($k % 2) -eq 1) ? (([BigNum]1).CloneWithNewResolution($wrkRes)) : (([BigNum]-1).CloneWithNewResolution($wrkRes)))

        $ck = ($sign * $powPart * $expPart) / $fact

		return $ck.Truncate($resolution)
	}

	# ReciprocalPow : INTERNAL USE. Returns the value of 1/N^p at $res resolution.
	hidden static [BigNum] ReciprocalPow([System.Numerics.BigInteger] $N,[int] $p,[System.Numerics.BigInteger] $res){
		# compute 1/N^p at working resolution
		$tmp = [BigNum]::new([System.Numerics.BigInteger]$N).CloneWithNewResolution($res)
		$tmpPow = [BigNum]::PowInt($tmp,$p)
		return ([BigNum]::new(1).CloneWithNewResolution($res) / $tmpPow).CloneWithNewResolution($res)
	}

	# EulerMascheroniGamma : Return the 1000 first digits of the Euler-Mascheroni Gamma constant.
	static [BigNum] EulerMascheroniGamma() {
		return [BigNum]::new("0.5772156649015328606065120900824024310421593359399235988057672348848677267776646709369470632917467495146314472498070824809605040144865428362241739976449235362535003337429373377376739427925952582470949160087352039481656708532331517766115286211995015079847937450857057400299213547861466940296043254215190587755352673313992540129674205137541395491116851028079842348775872050384310939973613725530608893312676001724795378367592713515772261027349291394079843010341777177808815495706610750101619166334015227893586796549725203621287922655595366962817638879272680132431010476505963703947394957638906572967929601009015125195950922243501409349871228247949747195646976318506676129063811051824197444867836380861749455169892792301877391072945781554316005002182844096053772434203285478367015177394398700302370339518328690001558193988042707411542227819716523011073565833967348717650491941812300040654693142999297779569303100503086303418569803231083691640025892970890985486825777364288253954925873629596133298574739302").CloneWithAdjustedResolution()
	}

	# EulerMascheroniGamma : (BigInteger) Return the $resolution first digits of the Euler-Mascheroni Gamma constant.
	static [BigNum] EulerMascheroniGamma([System.Numerics.BigInteger] $resolution) {
		if($resolution -lt 0){
			throw "Resolution for EulerMascheroniGamma must be a null or positive integer"
		}

		if (-not [BigNum]::cachedEulerMascheroniGamma) {
        	[BigNum]::cachedEulerMascheroniGamma = [BigNum]::EulerMascheroniGamma()
    	}

		[bool]$testAlwaysCompute = $false   # set $true when you want to force algorithm test
		if (-not $testAlwaysCompute) {
			if ($resolution -le 1000) {
				return [BigNum]::EulerMascheroniGamma().Truncate($resolution).CloneWithNewResolution($resolution)
			}

			if ($resolution -le [BigNum]::cachedEulerMascheroniGamma.GetMaxDecimalResolution()) {
				return [BigNum]::cachedEulerMascheroniGamma.Truncate($resolution).CloneWithNewResolution($resolution)
			}
		}


		# ------------- Working precision / guard digits -------------
		[int]$d = [int]$resolution
		[System.Numerics.BigInteger]$tmpGuard = 20
		if ($d -le 200){ [System.Numerics.BigInteger]$tmpGuard = 10 }
		if ($d -le 20) { [System.Numerics.BigInteger]$tmpGuard = 5 }
		[System.Numerics.BigInteger]$tmpWrk = $resolution + $tmpGuard

		# ------------- Coarse N heuristic -------------
		$Napprox = (([BigNum]$tmpWrk) * [BigNum]::Ln(([BigNum]10).CloneWithNewResolution($tmpWrk)) / ([BigNum]2).CloneWithNewResolution($tmpWrk)).Ceiling(0)
		if($Napprox -lt 10){ $Napprox = ([BigNum]10) }
		[System.Numerics.BigInteger]$N = $Napprox.Int()

		# ------------- Choose how many EM terms to include -------------
		$emExponents = @(2,4,6,8,10)
		[int]$maxEMExponent = $emExponents[-1]
		$nextExponent = $maxEMExponent + 2   # for remainder test

		# ------------- Remainder coefficient (at provisional precision) -------------
		$BnextProv   = [BigNum]::BernoulliNumberB($nextExponent,$tmpWrk)
		$coefNextProv = $BnextProv / ([BigNum]::new($nextExponent).CloneWithNewResolution($tmpWrk))
		$targetProv   = [BigNum]::PowTen(-$tmpWrk).CloneWithNewResolution($tmpWrk)
		
		# ------------- Refine N upward (cheap, provisional precision) -------------
		[System.Numerics.BigInteger]$Nmax = [System.Numerics.BigInteger]::Parse("10000000")  # tune
		do {
			$termChk = ($coefNextProv * [BigNum]::ReciprocalPow($N,$nextExponent,$tmpWrk)).Abs()
			if ($termChk -gt $targetProv) {
				$N += $N  # double
				if ($N -gt $Nmax) {
					throw "EulerMascheroniGamma(): N grew to $N (>1e7); remainder bound suspect."
				}
			}
		} while ($termChk -gt $targetProv)

		$N = $N / 2

		# ------------- compute Target -------------
		[BigNum]$target = [BigNum]::PowTen(-$tmpWrk).CloneWithNewResolution($tmpWrk)

		# ------------- compute H_N and ln N -------------
		[BigNum]$HN  = [BigNum]::HarmonicSeriesHn($N,$tmpWrk)
		[BigNum]$lnN = [BigNum]::Ln([BigNum]::new($N).CloneWithNewResolution($tmpWrk))

		[BigNum]$gamma = $HN - $lnN
		
		# -1/(2N)
		[BigNum]$Nbn = [BigNum]::new($N).CloneWithNewResolution($tmpWrk)
		$gamma -= ([BigNum]::new(1).CloneWithNewResolution($tmpWrk) / (2 * $Nbn))

		# + Sum_{k in emExponents} B_k/(k N^k)
		foreach($k in $emExponents) {
			$Bk = [BigNum]::BernoulliNumberB($k,$tmpWrk)
			$coef = $Bk / ([BigNum]::new($k).CloneWithNewResolution($tmpWrk))
			$Nk = [BigNum]::ReciprocalPow($N,$k,$tmpWrk)
			$term = $coef * $Nk
			$gamma += $term
			# Early break if term already insignificant
			if ($term.Abs() -le $target) { break }
		}

		# Store at the new resolution
		[BigNum]::cachedEulerMascheroniGamma = $gamma.Clone().Truncate($resolution).CloneWithNewResolution($resolution)

		# Return the new value
		return [BigNum]::cachedEulerMascheroniGamma.Clone()
	}

	# ClearCachedEulerMascheroniGamma : Clear the cached digits of the Euler-Mascheroni Gamma constant.
	static [void] ClearCachedEulerMascheroniGamma() {
    	[BigNum]::cachedEulerMascheroniGamma = $null
	}

	# AperyZeta3 : Return the 1000 first digits of the Apery Zeta(3) constant.
	static [BigNum] AperyZeta3() {
		return [BigNum]::new("1.2020569031595942853997381615114499907649862923404988817922715553418382057863130901864558736093352581461991577952607194184919959986732832137763968372079001614539417829493600667191915755222424942439615639096641032911590957809655146512799184051057152559880154371097811020398275325667876035223369849416618110570147157786394997375237852779370309560257018531827900030765471075630488433208697115737423807934450316076253177145354444118311781822497185263570918244899879620350833575617202260339378587032813126780799005417734869115253706562370574409662217129026273207323614922429130405285553723410330775777980642420243048828152100091460265382206962715520208227433500101529480119869011762595167636699817183557523488070371955574234729408359520886166620257285375581307928258648728217370556619689895266201877681062920081779233813587682842641243243148028217367450672069350762689530434593937503296636377575062473323992348288310773390527680200757984356793711505090050273660471140085335034364672248565315181177661810922").CloneWithAdjustedResolution()
	}

	# CatalanG : Return the 1000 first digits of Catalan G constant.
	static [BigNum] CatalanG() {
		return [BigNum]::new("0.9159655941772190150546035149323841107741493742816721342664981196217630197762547694793565129261151062485744226191961995790358988033258590594315947374811584069953320287733194605190387274781640878659090247064841521630002287276409423882599577415088163974702524820115607076448838078733704899008647751132259971343407485407553230768565335768095835260219382323950800720680355761048235733942319149829836189977069036404180862179411019175327431499782339761055122477953032487537187866582808236057022559419481809753509711315712615804242723636439850017382875977976530683700929808738874956108936597719409687268444416680462162433986483891628044828150627302274207388431172218272190472255870531908685735423498539498309919115967388464508615152499624237043745177737235177544070853846440132174839299994757244619975496197587064007474870701490937678873045869979860644874974643872062385137123927363049985035392239287879790633644032354784535851927777787270906083031994301332316712476158709792455479119092126201854803963934243").CloneWithAdjustedResolution()
	}

	# FeigenbaumA : Return the 1000 first digits of Feigenbaum A-constant.
	static [BigNum] FeigenbaumA() {
		return [BigNum]::new("2.5029078750958928222839028732182157863812713767271499773361920567792354631795902067032996497464338341295952318699958547239421823777854451792728633149933725781121635948795037447812609973805986712397117373289276654044010306698313834600094139322364490657889951220584317250787337746308785342428535198858750004235824691874082042817009017148230518216216194131998560661293827426497098440844701008054549677936760888126446406885181552709324007542506497157047047541993283178364533256241537869395712509706638797949265462313767459189098131167524342211101309131278371609511583412308415037164997020224681219644081216686527458043026245782561067150138521821644953254334987348741335279581535101658360545576351327650181078119483694595748502373982354526256327794753972699020128915166457939420198920248803394051699686551494477396533876979741232354061781989611249409599035312899773361184984737794610842883329383390395090089140863515256268033814146692799133107433497051435452013446434264752001621384610729922641994332772918").CloneWithAdjustedResolution()
	}

	# FeigenbaumDelta : Return the 1000 first digits of Feigenbaum Delta-constant.
	static [BigNum] FeigenbaumDelta() {
		return [BigNum]::new("4.6692016091029906718532038204662016172581855774757686327456513430041343302113147371386897440239480138171659848551898151344086271420279325223124429888908908599449354632367134115324817142199474556443658237932020095610583305754586176522220703854106467494942849814533917262005687556659523398756038256372256480040951071283890611844702775854285419801113440175002428585382498335715522052236087250291678860362674527213399057131606875345083433934446103706309452019115876972432273589838903794946257251289097948986768334611626889116563123474460575179539122045562472807095202198199094558581946136877445617396074115614074243754435499204869180982648652368438702799649017397793425134723808737136211601860128186102056381818354097598477964173900328936171432159878240789776614391395764037760537119096932066998361984288981837003229412030210655743295550388845849737034727532121925706958414074661841981961006129640161487712944415901405467941800198133253378592493365883070459999938375411726563553016862529032210862320550634").CloneWithAdjustedResolution()
	}

	# Sqrt2 : Return the 1000 first digits of Sqrt(2).
	static [BigNum] Sqrt2() {
		return [BigNum]::new("1.4142135623730950488016887242096980785696718753769480731766797379907324784621070388503875343276415727350138462309122970249248360558507372126441214970999358314132226659275055927557999505011527820605714701095599716059702745345968620147285174186408891986095523292304843087143214508397626036279952514079896872533965463318088296406206152583523950547457502877599617298355752203375318570113543746034084988471603868999706990048150305440277903164542478230684929369186215805784631115966687130130156185689872372352885092648612494977154218334204285686060146824720771435854874155657069677653720226485447015858801620758474922657226002085584466521458398893944370926591800311388246468157082630100594858704003186480342194897278290641045072636881313739855256117322040245091227700226941127573627280495738108967504018369868368450725799364729060762996941380475654823728997180326802474420629269124859052181004459842150591120249441341728531478105803603371077309182869314710171111683916581726889419758716582152128229518488472").CloneWithAdjustedResolution()
	}

	# Sqrt2 : (BigInteger) Return the $resolution first digits of Sqrt(2).
	static [BigNum] Sqrt2([System.Numerics.BigInteger] $resolution) {
		if($resolution -lt 0){
			throw "Resolution for Sqrt2 must be a null or positive integer"
		}

		if (-not [BigNum]::cachedSqrt2) {
        	[BigNum]::cachedSqrt2 = [BigNum]::Sqrt2()
    	}

		if ($resolution -le 1000) {
			return [BigNum]::Sqrt2().Truncate($resolution).CloneWithNewResolution($resolution)
		}

		if ($resolution -le [BigNum]::cachedSqrt2.GetMaxDecimalResolution()) {
			return [BigNum]::cachedSqrt2.Truncate($resolution).CloneWithNewResolution($resolution)
		}

		$tmpResolution = $resolution + 100
		[BigNum] $tmpSqrt2 = [BigNum]::Sqrt(([BigNum]2).CloneWithNewResolution($tmpResolution))
		
		# Store at the new resolution
		[BigNum]::cachedSqrt2 = $tmpSqrt2.Clone().Truncate($resolution).CloneWithNewResolution($resolution)

		# Return the new value
		return [BigNum]::cachedSqrt2.Clone()
	}

	# ClearCachedSqrt2 : Clear the cached digits of Sqrt(2).
	static [void] ClearCachedSqrt2() {
    	[BigNum]::cachedSqrt2 = $null
	}

	# Sqrt3 : Return the 1000 first digits of Sqrt(3).
	static [BigNum] Sqrt3() {
		return [BigNum]::new("1.7320508075688772935274463415058723669428052538103806280558069794519330169088000370811461867572485756756261414154067030299699450949989524788116555120943736485280932319023055820679748201010846749232650153123432669033228866506722546689218379712270471316603678615880190499865373798593894676503475065760507566183481296061009476021871903250831458295239598329977898245082887144638329173472241639845878553976679580638183536661108431737808943783161020883055249016700235207111442886959909563657970871684980728994932964842830207864086039887386975375823173178313959929830078387028770539133695633121037072640192491067682311992883756411414220167427521023729942708310598984594759876642888977961478379583902288548529035760338528080643819723446610596897228728652641538226646984200211954841552784411812865345070351916500166892944154808460712771439997629268346295774383618951101271486387469765459824517885509753790138806649619119622229571105552429237231921977382625616314688420328537166829386496119170497388363954959381").CloneWithAdjustedResolution()
	}

	# Sqrt3 : (BigInteger) Return the $resolution first digits of Sqrt(3).
	static [BigNum] Sqrt3([System.Numerics.BigInteger] $resolution) {
		if($resolution -lt 0){
			throw "Resolution for Sqrt3 must be a null or positive integer"
		}

		if (-not [BigNum]::cachedSqrt3) {
        	[BigNum]::cachedSqrt3 = [BigNum]::Sqrt3()
    	}

		if ($resolution -le 1000) {
			return [BigNum]::Sqrt3().Truncate($resolution).CloneWithNewResolution($resolution)
		}

		if ($resolution -le [BigNum]::cachedSqrt3.GetMaxDecimalResolution()) {
			return [BigNum]::cachedSqrt3.Truncate($resolution).CloneWithNewResolution($resolution)
		}

		$tmpResolution = $resolution + 100
		[BigNum] $tmpSqrt3 = [BigNum]::Sqrt(([BigNum]3).CloneWithNewResolution($tmpResolution))

		# Store at the new resolution
		[BigNum]::cachedSqrt3 = $tmpSqrt3.Clone().Truncate($resolution).CloneWithNewResolution($resolution)

		# Return the new value
		return [BigNum]::cachedSqrt3.Clone()
	}

	# ClearCachedSqrt3 : Clear the cached digits of Sqrt(3).
	static [void] ClearCachedSqrt3() {
    	[BigNum]::cachedSqrt3 = $null
	}

	# Cbrt2 : Return the 1000 first digits of Cbrt(2).
	static [BigNum] Cbrt2() {
		return [BigNum]::new("1.2599210498948731647672106072782283505702514647015079800819751121552996765139594837293965624362550941543102560356156652593990240406137372284591103042693552469606426166250009774745265654803068671854055186892458725167641993737096950983827831613991551293136953661839474634485765703031190958959847411059811629070535908164780114735213254847712978802422085820532579725266622026690056656081994715628176405060664826773572670419486207621442965694205079319172441480920448232840127470321964282081201905714188996459998317503801888689594202055922021154729973848802607363697417887792157984675099539630078260959624203483238660139857363433909737126527995991969968377913168168154428850279651529278107679714002040605674803938561251718357006907984996341976291474044834540269715476228513178020643878047649322579052898467085805286258130005429388560720609747223040631357234936458406575916916916727060124402896700001069081035313852902700415084232336239889386496782194149838027072957176812879001445746227147702348357151905506").CloneWithAdjustedResolution()
	}

	# Cbrt2 : (BigInteger) Return the $resolution first digits of Cbrt(2).
	static [BigNum] Cbrt2([System.Numerics.BigInteger] $resolution) {
		if($resolution -lt 0){
			throw "Resolution for Cbrt2 must be a null or positive integer"
		}

		if (-not [BigNum]::cachedCbrt2) {
        	[BigNum]::cachedCbrt2 = [BigNum]::Cbrt2()
    	}

		if ($resolution -le 1000) {
			return [BigNum]::Cbrt2().Truncate($resolution).CloneWithNewResolution($resolution)
		}

		if ($resolution -le [BigNum]::cachedCbrt2.GetMaxDecimalResolution()) {
			return [BigNum]::cachedCbrt2.Truncate($resolution).CloneWithNewResolution($resolution)
		}

		$tmpResolution = $resolution + 100
		[BigNum] $tmpCbrt2 = [BigNum]::Cbrt(([BigNum]2).CloneWithNewResolution($tmpResolution))
		
		# Store at the new resolution
		[BigNum]::cachedCbrt2 = $tmpCbrt2.Clone().Truncate($resolution).CloneWithNewResolution($resolution)

		# Return the new value
		return [BigNum]::cachedCbrt2.Clone()
	}

	# ClearCachedCbrt2 : Clear the cached digits of Cbrt(2).
	static [void] ClearCachedCbrt2() {
    	[BigNum]::cachedCbrt2 = $null
	}

	# Cbrt3 : Return the 1000 first digits of Cbrt(3).
	static [BigNum] Cbrt3() {
		return [BigNum]::new("1.4422495703074083823216383107801095883918692534993505775464161945416875968299973398547554797056452566868350808544895499664254239461102597148689501571852372270903320238475984450610855400272600881454988727513673553524678660747156884392233189182017038998238223321296166355085262673491335016654548957881758552741755933631318741467200604638466647569374364197555749424906820810942671235906265763689646373616178216558425874823856595235871903196104071395306028102853508443638035194550133809152223907849897509193948036531196743457062338119411183556576924832001231070159153329300428270666394443820480019012241818057851180278635499201489352352796818010900623683532797037372461456517341535339099046710530415693769030514949589952161665911663338019542272664828143118184417165535766881832140589503272799127928026983572135676304667631409826930968622476494140464484288713308799468418700020456187690275033046203665644407179091196980397474788838026707228447481594820872396116012271067171066612781813201108139530097227226").CloneWithAdjustedResolution()
	}

	# Cbrt3 : (BigInteger) Return the $resolution first digits of Cbrt(3).
	static [BigNum] Cbrt3([System.Numerics.BigInteger] $resolution) {
		if($resolution -lt 0){
			throw "Resolution for Cbrt3 must be a null or positive integer"
		}

		if (-not [BigNum]::cachedCbrt2) {
        	[BigNum]::cachedCbrt3 = [BigNum]::Cbrt3()
    	}

		if ($resolution -le 1000) {
			return [BigNum]::Cbrt3().Truncate($resolution).CloneWithNewResolution($resolution)
		}

		if ($resolution -le [BigNum]::cachedCbrt3.GetMaxDecimalResolution()) {
			return [BigNum]::cachedCbrt3.Truncate($resolution).CloneWithNewResolution($resolution)
		}

		$tmpResolution = $resolution + 100
		[BigNum] $tmpCbrt3 = [BigNum]::Cbrt(([BigNum]3).CloneWithNewResolution($tmpResolution))
		
		# Store at the new resolution
		[BigNum]::cachedCbrt3 = $tmpCbrt3.Clone().Truncate($resolution).CloneWithNewResolution($resolution)

		# Return the new value
		return [BigNum]::cachedCbrt3.Clone()
	}

	# ClearCachedCbrt3 : Clear the cached digits of Cbrt(3).
	static [void] ClearCachedCbrt3() {
    	[BigNum]::cachedCbrt3 = $null
	}

	# ClearAllCachedValues : Clear all the cached values.
	static [void] ClearAllCachedValues() {
		[BigNum]::cachedPi = $null
		[BigNum]::cachedTau = $null
		[BigNum]::cachedE = $null
		[BigNum]::cachedPhi = $null
		[BigNum]::cachedBernoulliNumberB = @{}
		[BigNum]::cachedEulerMascheroniGamma = $null
		[BigNum]::cachedSqrt2 = $null
		[BigNum]::cachedSqrt3 = $null
		[BigNum]::cachedCbrt2 = $null
    	[BigNum]::cachedCbrt3 = $null
	}

	#endregion Math Constants



	#region Physics Constants

	# c : Return the speed of light in a vacum. Expressed in Meters per Seconds. Exact value.
	static [BigNum] c() {
		#Expressed in Meters per Seconds
		#Exact value
		return [BigNum]::new("299792458")
	}

	# Plank_h : Return Plank's constant. Expressed in Joules . Seconds. Exact value.
	static [BigNum] Plank_h() {
		#Expressed in Joules . Seconds
		#Exact value
		return [BigNum]::new("0.000000000000000000000000000000000662607015")
	}

	# Plank_Reduced_h : Return Plank's Reduced constant. Expressed in Joules . Seconds. Aproximate value.
	static [BigNum] Plank_Reduced_h() {
		#Expressed in Joules . Seconds
		#Aproximate value
		return [BigNum]::new("0.0000000000000000000000000000000001054571817646156391262428003302281")
	}

	# Boltzmann_k : Return Boltzmanns's k constant. Expressed in Joules per Kelvin. Exact value.
	static [BigNum] Boltzmann_k() {
		#Expressed in Joules per Kelvin
		#Exact value
		return [BigNum]::new("0.00000000000000000000001380649")
	}

	# G : Return gravitational constant G. Expressed in Meters^3 per Kilogrammes per Seconds^2. Aproximate value.
	static [BigNum] G() {
		#Expressed in Meters^3 per Kilogrammes per Seconds^2
		#Aproximate value
		return [BigNum]::new("0.0000000000667430")
	}

	# Avogadro_Mole : Return the Avogadro constant. Expressed in 1/mol. Exact value as redefined in 2019 by the CGPM.
	static [BigNum] Avogadro_Mole() {
		#Avogadro's Constant. Expressed in 1/mol
		#Exact value as redefined in 2019 by the CGPM
		return [BigNum]::new("602214076000000000000000")
	}

	#endregion Physics Constants

}

#endregion Classes



function New-BigNum {
	[CmdletBinding()]
	param (
		[object] $val=[int]::Parse(0)
	)

	return New-Object -TypeName "BigNum" $val
}
