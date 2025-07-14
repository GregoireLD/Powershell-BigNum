
#region Classes

class BigNum : System.IComparable, System.IEquatable[Object] {

	hidden [System.Numerics.BigInteger] $integerVal
	hidden [System.Numerics.BigInteger] $shiftVal
	hidden [bool] $negativeFlag
	hidden [System.Numerics.BigInteger] $maxDecimalResolution
	hidden static [System.Numerics.BigInteger] $defaultMaxDecimalResolution = 100
	hidden static [BigNum] $cachedE
	hidden static [BigNum] $cachedPi
	hidden static [BigNum] $cachedTau
	hidden static [BigNum] $cachedPhi
	


	
	#region Constructors

	BigNum([System.Numerics.BigInteger]$intVal,[System.Numerics.BigInteger]$shift,[bool]$isNegative,[System.Numerics.BigInteger]$resolution) {
		$this.Init($intVal,$shift,$isNegative,$resolution)
    }

	BigNum() {
		$this.Init(0,0,$false,[BigNum]::defaultMaxDecimalResolution)
    }

	BigNum([int]$newVal) {
        $this.Init($newVal,0,$false,[BigNum]::defaultMaxDecimalResolution)
    }

	BigNum([float]$newVal) {
		$this.extractFromDouble($newVal)
    }

	BigNum([double]$newVal) {
		$this.extractFromDouble($newVal)
    }

	BigNum([decimal]$newVal) {
        $this.extractFromDecimal($newVal)
    }

	BigNum([System.Numerics.BigInteger]$newVal) {
        $this.Init($newVal,0,$false,[BigNum]::defaultMaxDecimalResolution)
    }

	BigNum([BigNum]$newVal) {
        $this.Init($newVal.integerVal,$newVal.shiftVal,$newVal.negativeFlag,$newVal.maxDecimalResolution)
    }

	BigNum([BigNum]$newVal,[System.Numerics.BigInteger]$newResolution) {
        $this.Init($newVal.integerVal,$newVal.shiftVal,$newVal.negativeFlag,$newResolution)
    }

	BigNum([System.Numerics.BigInteger]$newVal,[System.Numerics.BigInteger]$newShift) {
		$this.Init($newVal,$newShift,$false,[BigNum]::defaultMaxDecimalResolution+$newShift)
    }

	BigNum([System.Numerics.BigInteger]$newVal,[System.Numerics.BigInteger]$newShift,[System.Numerics.BigInteger]$newResolution) {
		$this.Init($newVal,$newShift,$false,$newResolution)
    }

	BigNum([string]$newVal) {
        $this.extractFromString($newVal)
    }

	#endregion Constructors



	#region Init

	[void] Init([System.Numerics.BigInteger]$intVal,[System.Numerics.BigInteger]$shift,[bool]$isNegative,[System.Numerics.BigInteger]$resolution) {
		$newNegative = $isNegative
		$tmpIntegerVal = [System.Numerics.BigInteger]::Abs($intVal)
		$tmpShift = [System.Numerics.BigInteger]::Parse($shift)

		if ($intVal -lt 0) {
			$newNegative = -not $newNegative
		}

		if($shift -lt 0){
			$shiftFactor = [BigNum]::Pow(10,$shift*(-1))
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

	#endregion Init



	#region Debug Accessors

	[System.Numerics.BigInteger]getIntegerVal(){
		return [System.Numerics.BigInteger]::Parse($this.integerVal)
	}
	[System.Numerics.BigInteger]getShiftVal(){
		return [System.Numerics.BigInteger]::Parse($this.shiftVal)
	}

	#endregion Debug Accessors



	#region Accessors

	[System.Numerics.BigInteger]getMaxDecimalResolution(){
		return [System.Numerics.BigInteger]::Parse($this.maxDecimalResolution)
	}

	[bool] IsNegative(){
		return $this.negativeFlag
	}

	[bool] IsPositive(){
		return (-not $this.negativeFlag)
	}

	#endregion Accessors



	#region Extractors

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

	#endregion Extractors



	#region ResolutionModifiers

	[BigNum]ChangeResolution([System.Numerics.BigInteger]$newDecimalResolution) {
		return [BigNum]::new($this,$newDecimalResolution)

	}

	[BigNum]resetMaxDecimalResolution() {
		return [BigNum]::new($this,[BigNum]::defaultMaxDecimalResolution)

	}

	#endregion ResolutionModifiers



	#region IComparable Implementation

	[int] CompareTo([object] $other) {
		# Simply perform (case-insensitive) lexical comparison on the .Kind
		# property values.
		if ($null -eq $other) {return 1}
		[BigNum] $tmpOther = $other

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

	[int] GetHashCode() {
		return ("" + $this.ToString() + "/" + $this.maxDecimalResolution).GetHashCode()
    }

	#endregion IComparable Implementation


	
	#region IEquatable Implementation

	[bool] Equals([object] $other) {
		$isEqual = $true
		if($this.integerVal -ne $other.integerVal){
			$isEqual = $false
		}
		if($this.shiftVal -ne $other.shiftVal){
			$isEqual = $false
		}
		if($this.negativeFlag -ne $other.negativeFlag){
			$isEqual = $false
		}
		return $isEqual
    }

	#endregion IEquatable Implementation



	#region Base Operators

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

		return [BigNum]::new($tmpA + $tmpB,[System.Numerics.BigInteger]::Max($a.shiftVal,$b.shiftVal),$newDecimalResolution)
	}

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

		return [BigNum]::new($tmpA - $tmpB,[System.Numerics.BigInteger]::Max($a.shiftVal,$b.shiftVal),$newDecimalResolution)
	}

	static [BigNum] op_Multiply([BigNum] $a, [BigNum] $b) {
		[System.Numerics.BigInteger]$tmpA = $a.integerVal
	  	[System.Numerics.BigInteger]$tmpB = $b.integerVal
		[System.Numerics.BigInteger]$newDecimalResolution = [System.Numerics.BigInteger]::Max($a.maxDecimalResolution,$b.maxDecimalResolution)
	  
	  	if ($a.negativeFlag) { $tmpA *= -1 }
	  	if ($b.negativeFlag) { $tmpB *= -1 }

		return [BigNum]::new($tmpA * $tmpB,$a.shiftVal + $b.shiftVal,$newDecimalResolution)
	}

	static [BigNum] op_Division([BigNum] $a, [BigNum] $b) {
		[System.Numerics.BigInteger]$tmpA = $a.integerVal
	  	[System.Numerics.BigInteger]$tmpB = $b.integerVal
		[System.Numerics.BigInteger]$newDecimalResolution = [System.Numerics.BigInteger]::Max($a.maxDecimalResolution,$b.maxDecimalResolution)

	  	if ($a.negativeFlag) { $tmpA *= -1 }
	  	if ($b.negativeFlag) { $tmpB *= -1 }

		$tmpA *= [BigNum]::PowTenPositive($newDecimalResolution + $b.shiftVal)

		return [BigNum]::new($tmpA / $tmpB,$newDecimalResolution + $a.shiftVal,$newDecimalResolution)
	}

	static [BigNum] op_Modulus([BigNum] $a, [System.Numerics.BigInteger] $b) {
		[System.Numerics.BigInteger]$tmpA = $a.Int()
		[System.Numerics.BigInteger]$tmpModed = $tmpA % $b

		[BigNum]$tmpResult = $a - [BigNum]$tmpA
		[BigNum]$tmpResult += $tmpModed

		return $tmpResult.CloneWithNewRes($a.maxDecimalResolution)
	}

	static [BigNum] op_LeftShift([BigNum] $a, [System.Numerics.BigInteger] $b) {
		[System.Numerics.BigInteger]$tmpA = $a.integerVal
		[System.Numerics.BigInteger]$newShiftVal = $a.shiftVal - $b

		if ($newShiftVal -lt 0) {
			$tmpA *= [BigNum]::PowTenPositive(-$newShiftVal)
			$newShiftVal=0
		}

		return [BigNum]::new($tmpA,$newShiftVal,$a.negativeFlag,$a.getMaxDecimalResolution())
	}

	static [BigNum] op_RightShift([BigNum] $a, [System.Numerics.BigInteger] $b) {
		[System.Numerics.BigInteger]$tmpA = $a.integerVal
		[System.Numerics.BigInteger]$newShiftVal = $a.shiftVal + $b

		return [BigNum]::new($tmpA,$newShiftVal,$a.negativeFlag,$a.getMaxDecimalResolution())
	}

	# -bxor   op_ExclusiveOr
	# -band   op_BitwiseAnd
	# -bor    op_BitwiseOr
	# -bnot   op_OnesComplement

	#endregion Base Operators



	#region Additional Operators

	[System.Numerics.BigInteger] Int() {
		$strTmp = $this.integerVal.ToString()
		$lastPos=$strTmp.Length-$this.shiftVal
		if ($lastPos -lt 0) {
			return ([System.Numerics.BigInteger]0)
		}
		return [System.Numerics.BigInteger]::Parse($strTmp.Substring(0,$lastPos))
	}

	[BigNum] Abs() {
		return [BigNum]::new($this.integerVal,$this.shiftVal,$false,$this.maxDecimalResolution)
	}

	hidden static [System.Numerics.BigInteger] EstimateTaylorTermsForLn([BigNum] $x, [System.Numerics.BigInteger] $decimalLenght) {
		[System.Numerics.BigInteger] $n = 1
		[System.Numerics.BigInteger] $targetDecimalLenght = [System.Numerics.BigInteger]::Max($decimalLenght,$x.maxDecimalResolution)+10
		[BigNum] $targetEpsilon = [BigNum]::new("1",$targetDecimalLenght,$false,$targetDecimalLenght)
		[BigNum] $currentPower = $x.ChangeResolution($targetDecimalLenght)

		while (($currentPower.Abs() / $n) -gt $targetEpsilon) {
			$n += 1
			$currentPower *= $x
		}

		return $n
	}

	hidden static [System.Numerics.BigInteger] EstimateTaylorTermsForExp([BigNum] $x, [System.Numerics.BigInteger] $decimalLength) {
		#This function requires a scaled $x value
		[System.Numerics.BigInteger] $n = 1
		[System.Numerics.BigInteger] $targetDecimalLenght = [System.Numerics.BigInteger]::Max($decimalLength,$x.maxDecimalResolution)+10
		[BigNum] $absX = $x.Abs().ChangeResolution($targetDecimalLenght)
		[BigNum] $term = $absX.ChangeResolution($targetDecimalLenght)
		[BigNum] $factorial = [BigNum]::Parse("1").ChangeResolution($targetDecimalLenght)
		[BigNum] $targetEpsilon = [BigNum]::new(1,$decimalLength,$false,$targetDecimalLenght)
		[System.Numerics.BigInteger] $hardLimit = 10000

		while ((($term / $factorial) -gt $targetEpsilon) -and ($n -lt $hardLimit)) {
			$n += 1
			$term *= $absX
			$factorial *= [BigNum]::Parse($n).ChangeResolution($targetDecimalLenght)
		}

		if ($n -ge $hardLimit) {
			throw "[BigNum]::EstimateTaylorTermsForExp reached hard limit ($hardLimit) without convergence"
		}

		return $n
	}

	static [BigNum] Ln([BigNum] $value) {
		# Trap illegal values
		if ($value -le 0) {
			throw "[BigNum]::Ln() function is not defined for zero nor negative numbers"
		}

		$tmpResolution = $value.maxDecimalResolution + 100
		
		[BigNum] $tmpVal = $value.CloneWithNewRes($tmpResolution)
		[BigNum] $tmpOne = [BigNum]::new("1.0").ChangeResolution($tmpResolution)
		[BigNum] $tmpQuarter = [BigNum]::new("0.25").ChangeResolution($tmpResolution)
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
		[BigNum] $tmpT = [BigNum]::new(0).ChangeResolution($tmpResolution)
		[BigNum] $tmpS = [BigNum]::new(1).ChangeResolution($tmpResolution)
		[BigNum] $tmpZ = $tmpVal.CloneWithNewRes($tmpResolution)

		for ([BigNum]$k = 1; $k -le $TAYLOR_ITERATIONS; $k += 1) {
			$tmpT += $tmpZ * $tmpS / $k
			$tmpZ *= $tmpVal
			$tmpS *= -1
		}
		
		# Combine the result with the power_adjust value and return
		return [BigNum]::new($tmpT+$powerAdjust).Crop($value.maxDecimalResolution).ChangeResolution($value.maxDecimalResolution)
	}

	static [BigNum] Exp([BigNum] $exponent) {

		# threshold where we start scaling
		$threshold = [BigNum]::new(1)

		$tmpResolution = $exponent.maxDecimalResolution + 100

		[BigNum] $absX = $exponent.Abs()
		[System.Numerics.BigInteger] $k = 0
		$constTwo = ([BigNum]2).ChangeResolution($tmpResolution)

		# Find k such that |x / 2^k| < threshold
		while ($absX -gt $threshold) {
			$absX /= $constTwo
			$k += 1
		}

		# Compute smallExp = e^(x / 2^k)
		$scaledX = $exponent / [BigNum]::new([System.Numerics.BigInteger]::Pow(2, $k))
		$numTerms = [BigNum]::EstimateTaylorTermsForExp($scaledX, $tmpResolution)

		[BigNum] $result = [BigNum]::new(1).ChangeResolution($tmpResolution)
		[BigNum] $term = [BigNum]::new(1).ChangeResolution($tmpResolution)
		[BigNum] $factorial = [BigNum]::new(1).ChangeResolution($tmpResolution)

		for ([System.Numerics.BigInteger] $n = 1; $n -le $numTerms; $n += 1) {
			$term *= $scaledX
			$factorial *= [BigNum]::new($n).ChangeResolution($tmpResolution)
			$result += $term / $factorial
		}

		# Square result k times
		for ([System.Numerics.BigInteger] $i = 0; $i -lt $k; $i += 1) {
			$result *= $result
		}

		return $result.Clone().Crop($exponent.maxDecimalResolution).ChangeResolution($exponent.maxDecimalResolution)
	}

	static [BigNum] Log([BigNum] $value, [BigNum] $base) {
		if (($base -le 0) -or ($base -eq [BigNum]::new(1))) {
			throw "[BigNum]::Log() error: base must be positive and not equal to 1"
		}
		if ($value -le 0) {
			throw "[BigNum]::Log() error: logarithm is not defined for non-positive values"
		}

		$targetResolution = ([BigNum]::Max($value.maxDecimalResolution,$base.maxDecimalResolution)).Int()
		$tmpResolutionPlus = $targetResolution + 100

		[BigNum] $lnValue = [BigNum]::Ln($value.CloneWithNewRes($tmpResolutionPlus))
		[BigNum] $lnBase = [BigNum]::Ln($base.CloneWithNewRes($tmpResolutionPlus))

		return [BigNum]::new($lnValue / $lnBase).Crop($targetResolution).ChangeResolution($targetResolution)
	}

	static [BigNum] Pow([BigNum] $value, [BigNum] $exponent) {
		if($exponent.IsInteger() -and $exponent.IsInteger() -and ($exponent -ge 0)) {
			return [BigNum]::IntPow($value, $exponent.Int())
		}
		return [BigNum]::FloatPow($value, $exponent)
	}

	hidden static [BigNum] IntPow([BigNum] $value, [System.Numerics.BigInteger] $exponent) {
		[System.Numerics.BigInteger] $residualExp = [System.Numerics.BigInteger]::Parse($exponent);
		[System.Numerics.BigInteger] $intValue = [System.Numerics.BigInteger]::Parse($value.integerVal)
		if ($value.IsNegative()) { $intValue *= -1 }
		[System.Numerics.BigInteger] $shiftValue = [System.Numerics.BigInteger]::Parse($value.shiftVal)
		[System.Numerics.BigInteger] $total = 1
		[System.Numerics.BigInteger] $maxPow = 0

     	while ($residualExp -gt [int16]::MaxValue) {
			if ($maxPow -eq 0) {
				$maxPow = [System.Numerics.BigInteger]::Pow($intValue, [int16]::MaxValue);
			}
        	$residualExp -= [int16]::MaxValue
        	$total *= $maxPow
     	}

     	$total *= [System.Numerics.BigInteger]::Pow($intValue, [int16]$residualExp);
		return [BigNum]::new($total,$shiftValue*$exponent,$false,$value.maxDecimalResolution)
	}

	hidden static [BigNum] FloatPow([BigNum] $value, [BigNum] $exponent) {
		if ($value.negativeFlag) {
			throw "[BigNum]::Pow is not capable of handling complex value output"
		}
		return [BigNum]::new([BigNum]::Exp(($exponent*([BigNum]::Ln($value)))),$value.maxDecimalResolution)
	}

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

	hidden static [BigNum] PowTen([System.Numerics.BigInteger] $exponent) {
		if ($exponent -ge 0) { return [BigNum]::Parse([BigNum]::PowTenPositive($exponent)) }
		$tmpExp = -$exponent
		return [BigNum]::new(1,$tmpExp,$false,$tmpExp)
	}

	static [BigNum] Sqrt([BigNum] $value) {
		if ($value.IsNegative()) {
        	throw "[BigNum]::Sqrt() is not defined for negative numbers"
		}

		$tmpResolution = $value.maxDecimalResolution + 10
		$tmpValue = $value.CloneWithNewRes($tmpResolution)
		$constOne = [BigNum]::new(1).ChangeResolution($tmpResolution)

		# Initial guess: S / 2 or 1 if S < 1
    	# [BigNum] $x = ($tmpValue -lt $constOne) ? $constOne.clone() : ($tmpValue / $constTwo)
		[BigNum] $x = ($tmpValue -lt $constOne) ? ([BigNum]::PowTen(-($tmpValue.shiftVal-1-$tmpValue.integerVal.ToString().Length))) : (($tmpValue.integerVal.ToString().Length%2)?([BigNum]::PowTen(($tmpValue.integerVal.ToString().Length - 1)/2)):([BigNum]::PowTen($tmpValue.integerVal.ToString().Length/2)))
		# Convergence threshold
    	[BigNum] $epsilon = [BigNum]::PowTen(-$tmpResolution).ChangeResolution($tmpResolution)


		[BigNum] $half = [BigNum]::new(0.5).ChangeResolution($tmpResolution)
    	[BigNum] $diff = $constOne.clone()

		do {
			$prev_x = $x
			$x = $half * ($x + ($tmpValue / $x))
			$diff = ($x - $prev_x).Abs()
		} while ($diff -gt $epsilon)

		# Return cropped to user-specified resolution
		return $x.Clone().Crop($value.maxDecimalResolution).ChangeResolution($value.maxDecimalResolution)
	}

	static [BigNum] Cbrt([BigNum] $value) {
		return [BigNum]::NthRootInt($value,3)
	}

	hidden static [BigNum] NthRootInt([BigNum] $value, [System.Numerics.BigInteger] $n) {
		if ($n -eq 0) {
			throw "[BigNum]::NthRootInt() - exponent 'n' cannot be zero"
		}

		if ($value -lt 0 -and (($n % 2) -eq 0)) {
			throw "[BigNum]::NthRootInt() cannot compute even roots of negative numbers"
		}

		# Setup high resolution for internal calculations
		$tmpResolution = $value.maxDecimalResolution + 10
		$tmpValue = $value.CloneWithNewRes($tmpResolution)
		$x = [BigNum]::PowTen(0)

		# Initial guess: 10 ^ floor(numDigits / n)
		if(($tmpValue -lt 1) -and ($tmpValue -gt -1)){
			$x = [BigNum]::PowTen(-($tmpValue.shiftVal-1-$tmpValue.integerVal.ToString().Length)).ChangeResolution($tmpResolution)
		} else {
			$numDigits = $tmpValue.integerVal.ToString().Length
			$approxExp = $numDigits / $n
			$x = [BigNum]::PowTen($approxExp).ChangeResolution($tmpResolution)
		}

		# Precompute constants
		$nBig = [BigNum]::new($n).ChangeResolution($tmpResolution)
		$nMinusOne = $nBig - 1
		$epsilon = [BigNum]::PowTen(5-$tmpResolution).ChangeResolution($tmpResolution)

		# Newton-Raphson iterations
		$diff = $x
		do {
			$xPrev = $x
			$xPower = [BigNum]::Pow($x, $nMinusOne)
			$x = (($nMinusOne * $x) + ($tmpValue / $xPower)) / $nBig
			$diff = ($x - $xPrev).Abs()
		} while ($diff -gt $epsilon)

		# Return cropped to requested resolution
		return $x.Crop($value.maxDecimalResolution).ChangeResolution($value.maxDecimalResolution)
	}

	static [BigNum] NthRoot([BigNum] $value, [BigNum] $n) {
		if ($n -eq 0) {
			throw "[BigNum]::NthRoot() - exponent 'n' cannot be zero"
		}

		if($n.IsInteger()) {
			return [BigNum]::NthRootInt($value,$n.integerVal*(($n -lt 0)?-1:1))
		}

		$constTwo = [BigNum]::new(2)

		if (($value -lt 0) -and ((-not $n.IsInteger()) -or (($n % $constTwo) -eq 0))) {
			throw "[BigNum]::NthRoot() - negative base with non-odd integer root leads to complex result"
		}

		$tmpResolution = $value.maxDecimalResolution + 10
		$tmpValue = $value.CloneWithNewRes($tmpResolution)
		$x = [BigNum]::PowTen(0)

		# Initial guess: 10 ^ (numDigits / n)
		if(($tmpValue -lt 1) -and ($tmpValue -gt -1)){
			$x = [BigNum]::PowTen(-($tmpValue.shiftVal-1-$tmpValue.integerVal.ToString().Length)).ChangeResolution($tmpResolution)
		} else {
			$numDigits = [BigNum]::Parse($tmpValue.integerVal.ToString().Length)
			$approxExp = $numDigits / $n
			$x = [BigNum]::PowTen($approxExp.Round(0).Int()).ChangeResolution($tmpResolution)
		}

		# Precompute constants
		$constOne = [BigNum]::new(1).ChangeResolution($tmpResolution)
		# $constTwo = [BigNum]::new(2).ChangeResolution($tmpResolution)
		$epsilon = [BigNum]::PowTen(5-$tmpResolution).ChangeResolution($tmpResolution)

		$diff = $x
		do {
			$xPrev = $x
			$xPowerN = [BigNum]::Pow($x, $n)
			$xPowerNminus1 = [BigNum]::Pow($x, $n - $constOne)
			$x = $x - (($xPowerN - $tmpValue) / ($n * $xPowerNminus1))
			$diff = ($x - $xPrev).Abs()
		} while ($diff -gt $epsilon)

		return $x.Crop($value.maxDecimalResolution).ChangeResolution($value.maxDecimalResolution)
	}

	# static [BigNum] ModPow([BigNum] $value, [int] $exponent, [System.Numerics.BigInteger] $modulus) {
	# 	return [BigNum]::new([System.Numerics.BigInteger]::ModPow($this.integerVal,$exponent.val,$modulus.val))
	# }

	#endregion Additional Operators



	#region Methods

	[string] ToString() {
		$numberFormat = (Get-Culture).NumberFormat
		$deciChar = $numberFormat.NumberDecimalSeparator
		$negChar = $numberFormat.negativeSign

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

		return $strBuilder
	}

	static [BigNum] Parse([object] $val) {
		return [BigNum]::new($val)
	}

	static [BigNum] Min([BigNum] $a,[BigNum] $b) {
		if ($a -lt $b) {
			return [BigNum]::new($a)
		}
		return [BigNum]::new($b)
	}

	static [BigNum] Max([BigNum] $a,[BigNum] $b) {
		if ($a -gt $b) {
			return [BigNum]::new($a)
		}
		return [BigNum]::new($b)
	}

	[bool] IsInteger() {
		if ($this.shiftVal -eq 0) {
			return $true
		}
		return $false
	}

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

	[BigNum] RoundUp([System.Numerics.BigInteger]$decimals){
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

	[BigNum] RoundDown([System.Numerics.BigInteger]$decimals){
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

	[BigNum] RoundTowardZero([System.Numerics.BigInteger]$decimals){
		$alteration = 0

		$newValStr += "" + "0" + $this.integerVal.ToString()
		[System.Numerics.BigInteger]$newVal = [System.Numerics.BigInteger]::Parse($newValStr)
		$toRound = $this.shiftVal - $decimals
		$newShift = $this.shiftVal
		$newSign = $this.negativeFlag

		if ($toRound -gt 0) {
			if ($toRound -gt ($newValStr.Length - 1)) {
				$newVal = "0"
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
				if (($newVal -eq 0) -and ($alteration -eq 0)) {
					$newSign = $false
				}
				
				$newVal += $alteration
				$newShift = $decimals
			}
		}

		return [BigNum]::new($newVal,$newShift,$newSign,$this.maxDecimalResolution)
	}

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

	[BigNum] Crop([System.Numerics.BigInteger]$decimals) {
		$tmpVal = [System.Numerics.BigInteger]::Parse($this.integerVal)
		[string]$tmpString = $tmpString = $tmpVal.ToString()
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

	[BigNum] Clone() {
		return [BigNum]::new($this.integerVal,$this.shiftVal,$this.negativeFlag,$this.maxDecimalResolution)
	}

	[BigNum] CloneWithNewRes([System.Numerics.BigInteger] $newResolution) {
		return [BigNum]::new($this.integerVal,$this.shiftVal,$this.negativeFlag,$newResolution)
	}

	#endregion Methods



	#region Math Constants

	static [BigNum] Pi() {
		return [BigNum]::new("3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679821480865132823066470938446095505822317253594081284811174502841027019385211055596446229489549303819644288109756659334461284756482337867831652712019091456485669234603486104543266482133936072602491412737245870066063155881748815209209628292540917153643678925903600113305305488204665213841469519415116094330572703657595919530921861173819326117931051185480744623799627495673518857527248912279381830119491298336733624406566430860213949463952247371907021798609437027705392171762931767523846748184676694051320005681271452635608277857713427577896091736371787214684409012249534301465495853710507922796892589235420199561121290219608640344181598136297747713099605187072113499999983729780499510597317328160963185950244594553469083026425223082533446850352619311881710100031378387528865875332083814206171776691473035982534904287554687311595628638823537875937519577818577805321712268066130019278766111959092164201989").ChangeResolution(1000)
	}

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
			return [BigNum]::Pi().Crop($resolution).ChangeResolution($resolution)
		}

		if ($resolution -le [BigNum]::cachedPi.getMaxDecimalResolution()) {
			return [BigNum]::cachedPi.Crop($resolution).ChangeResolution($resolution)
		}

		$tmpResolution = $resolution + 5

		$a = [BigNum]::new(1).ChangeResolution($tmpResolution)
		$b = [BigNum]::new(1).ChangeResolution($tmpResolution) / [BigNum]::Sqrt(([BigNum]2).ChangeResolution($tmpResolution))
		$p = [BigNum]::new(1).ChangeResolution($tmpResolution)
		$t = [BigNum]::new(0.25).ChangeResolution($tmpResolution)

		$constTwo = [BigNum]::new(2).ChangeResolution($tmpResolution)
		$constFour = [BigNum]::new(4).ChangeResolution($tmpResolution)
		$referenceDiff = [BigNum]::PowTen(-$resolution).ChangeResolution($tmpResolution)

		$tmpPi = [BigNum]::new(3).ChangeResolution($tmpResolution)
		$diff = [BigNum]::new("0.14").ChangeResolution($tmpResolution)

		do {
			$tmpPi_old = $tmpPi

			$a_next = ($a + $b) / $constTwo
			$b_next = [BigNum]::Sqrt(($a * $b).ChangeResolution($tmpResolution))
			$p_next = $constTwo * $p
			$t_next = $t - ($p * [BigNum]::Pow($a_next - $a,2))

			$a = $a_next
			$b = $b_next
			$p = $p_next
			$t = $t_next

			$tmpPi = (($a + $b) * ($a + $b)) / ($constFour * $t)
			$diff = ($tmpPi - $tmpPi_old).Abs()
		} while ($diff -gt $referenceDiff)

		[BigNum]::cachedPi = [BigNum]::new([BigNum]$tmpPi).Crop($resolution).ChangeResolution($resolution)
		[BigNum]::cachedTau = ([BigNum]::cachedPi * 2).Crop($resolution).ChangeResolution($resolution)

		return [BigNum]::cachedPi.Clone()
	}

	static [void] ClearCachedPi() {
    	[BigNum]::cachedPi = $null
	}

	static [BigNum] Tau() {
		return [BigNum]::new("6.2831853071795864769252867665590057683943387987502116419498891846156328125724179972560696506842341359642961730265646132941876892191011644634507188162569622349005682054038770422111192892458979098607639288576219513318668922569512964675735663305424038182912971338469206972209086532964267872145204982825474491740132126311763497630418419256585081834307287357851807200226610610976409330427682939038830232188661145407315191839061843722347638652235862102370961489247599254991347037715054497824558763660238982596673467248813132861720427898927904494743814043597218874055410784343525863535047693496369353388102640011362542905271216555715426855155792183472743574429368818024499068602930991707421015845593785178470840399122242580439217280688363196272595495426199210374144226999999967459560999021194634656321926371900489189106938166052850446165066893700705238623763420200062756775057731750664167628412343553382946071965069808575109374623191257277647075751875039155637155610643424536132260038557532223918184328403978").ChangeResolution(1000)
	}

	static [BigNum] Tau([System.Numerics.BigInteger] $resolution) {
		if($resolution -lt 0){
			throw "Resolution for Tau must be a null or positive integer"
		}

		if (-not [BigNum]::cachedTau) {
        	[BigNum]::cachedTau = [BigNum]::Tau()
    	}

		if ($resolution -le 1000) {
			return [BigNum]::Tau().Crop($resolution).ChangeResolution($resolution)
		}

		if ($resolution -le [BigNum]::cachedTau.getMaxDecimalResolution()) {
			return [BigNum]::cachedTau.Crop($resolution).ChangeResolution($resolution)
		}

		[BigNum]::Pi($resolution)

		return [BigNum]::cachedTau.Clone()
	}

	static [void] ClearCachedTau() {
    	[BigNum]::cachedTau = $null
	}

	static [BigNum] e() {
		# 1000 decimal long
		return [BigNum]::new("2.7182818284590452353602874713526624977572470936999595749669676277240766303535475945713821785251664274274663919320030599218174135966290435729003342952605956307381323286279434907632338298807531952510190115738341879307021540891499348841675092447614606680822648001684774118537423454424371075390777449920695517027618386062613313845830007520449338265602976067371132007093287091274437470472306969772093101416928368190255151086574637721112523897844250569536967707854499699679468644549059879316368892300987931277361782154249992295763514822082698951936680331825288693984964651058209392398294887933203625094431173012381970684161403970198376793206832823764648042953118023287825098194558153017567173613320698112509961818815930416903515988885193458072738667385894228792284998920868058257492796104841984443634632449684875602336248270419786232090021609902353043699418491463140934317381436405462531520961836908887070167683964243781405927145635490613031072085103837505101157477041718986106873969655212671546889570350354").ChangeResolution(1000)
	}

	static [BigNum] e([System.Numerics.BigInteger] $resolution) {
		if($resolution -lt 0){
			throw "Resolution for e must be a null or positive integer"
		}

		if (-not [BigNum]::cachedE) {
        	[BigNum]::cachedE = [BigNum]::e()
    	}

		if ($resolution -le 1000) {
			return [BigNum]::e().Crop($resolution).ChangeResolution($resolution)
		}

		if ($resolution -le [BigNum]::cachedE.getMaxDecimalResolution()) {
			return [BigNum]::cachedE.Crop($resolution).ChangeResolution($resolution)
		}

		$tmpResolution = $resolution + 100
		[BigNum] $result = [BigNum]::new(1).ChangeResolution($tmpResolution)
		[BigNum] $factorial = [BigNum]::new(1).ChangeResolution($tmpResolution)

		for ([System.Numerics.BigInteger]$n = 1; $n -le $tmpResolution; $n += 1) {
			$factorial *= [BigNum]::new($n)
			$result += [BigNum]::new(1) / $factorial
		}

		[BigNum]::cachedE = [BigNum]::new($result).Crop($resolution).ChangeResolution($resolution)

		return [BigNum]::cachedE.Clone()
	}

	static [void] ClearCachedE() {
    	[BigNum]::cachedE = $null
	}

	static [BigNum] phi() {
		return [BigNum]::new("1.6180339887498948482045868343656381177203091798057628621354486227052604628189024497072072041893911374847540880753868917521266338622235369317931800607667263544333890865959395829056383226613199282902678806752087668925017116962070322210432162695486262963136144381497587012203408058879544547492461856953648644492410443207713449470495658467885098743394422125448770664780915884607499887124007652170575179788341662562494075890697040002812104276217711177780531531714101170466659914669798731761356006708748071013179523689427521948435305678300228785699782977834784587822891109762500302696156170025046433824377648610283831268330372429267526311653392473167111211588186385133162038400522216579128667529465490681131715993432359734949850904094762132229810172610705961164562990981629055520852479035240602017279974717534277759277862561943208275051312181562855122248093947123414517022373580577278616008688382952304592647878017889921990270776903895321968198615143780314997411069260886742962267575605231727775203536139362").ChangeResolution(1000)
	}

	static [BigNum] phi([System.Numerics.BigInteger] $resolution) {
		if($resolution -lt 0){
			throw "Resolution for phi must be a null or positive integer"
		}

		if (-not [BigNum]::cachedPhi) {
        	[BigNum]::cachedPhi = [BigNum]::phi()
    	}

		if ($resolution -le 1000) {
			return [BigNum]::phi().Crop($resolution).ChangeResolution($resolution)
		}

		if ($resolution -le [BigNum]::cachedPhi.getMaxDecimalResolution()) {
			return [BigNum]::cachedPhi.Crop($resolution).ChangeResolution($resolution)
		}

		$tmpResolution = $resolution + 100

		# First, define a few high-res constants
		[BigNum] $constOne = [BigNum]::new(1).ChangeResolution($tmpResolution)
		[BigNum] $constTwo = [BigNum]::new(2).ChangeResolution($tmpResolution)
		[BigNum] $constFive = [BigNum]::new(5).ChangeResolution($tmpResolution)

		# Then, get the square root of 5
		[BigNum] $constSqrt5 = [BigNum]::Sqrt($constFive)
		
		# Then calculate (1 + sqrt(5)) / 2
		[BigNum] $tmpPhi = ($constOne + $constSqrt5) / $constTwo
		
		# Store at the new resolution
		[BigNum]::cachedPhi = $tmpPhi.Clone().Crop($resolution).ChangeResolution($resolution)

		# Return the new value
		return [BigNum]::cachedPhi.Clone()
	}

	static [void] ClearCachedPhi() {
    	[BigNum]::cachedPhi = $null
	}

	static [BigNum] sqrt2() {
		return [BigNum]::new("1.4142135623730950488016887242096980785696718753769480731766797379907324784621070388503875343276415727350138462309122970249248360558507372126441214970999358314132226659275055927557999505011527820605714701095599716059702745345968620147285174186408891986095523292304843087143214508397626036279952514079896872533965463318088296406206152583523950547457502877599617298355752203375318570113543746034084988471603868999706990048150305440277903164542478230684929369186215805784631115966687130130156185689872372352885092648612494977154218334204285686060146824720771435854874155657069677653720226485447015858801620758474922657226002085584466521458398893944370926591800311388246468157082630100594858704003186480342194897278290641045072636881313739855256117322040245091227700226941127573627280495738108967504018369868368450725799364729060762996941380475654823728997180326802474420629269124859052181004459842150591120249441341728531478105803603371077309182869314710171111683916581726889419758716582152128229518488472")
	}

	static [BigNum] sqrt3() {
		return [BigNum]::new("1.7320508075688772935274463415058723669428052538103806280558069794519330169088000370811461867572485756756261414154067030299699450949989524788116555120943736485280932319023055820679748201010846749232650153123432669033228866506722546689218379712270471316603678615880190499865373798593894676503475065760507566183481296061009476021871903250831458295239598329977898245082887144638329173472241639845878553976679580638183536661108431737808943783161020883055249016700235207111442886959909563657970871684980728994932964842830207864086039887386975375823173178313959929830078387028770539133695633121037072640192491067682311992883756411414220167427521023729942708310598984594759876642888977961478379583902288548529035760338528080643819723446610596897228728652641538226646984200211954841552784411812865345070351916500166892944154808460712771439997629268346295774383618951101271486387469765459824517885509753790138806649619119622229571105552429237231921977382625616314688420328537166829386496119170497388363954959381")
	}

	static [BigNum] cbrt2() {
		return [BigNum]::new("1.2599210498948731647672106072782283505702514647015079800819751121552996765139594837293965624362550941543102560356156652593990240406137372284591103042693552469606426166250009774745265654803068671854055186892458725167641993737096950983827831613991551293136953661839474634485765703031190958959847411059811629070535908164780114735213254847712978802422085820532579725266622026690056656081994715628176405060664826773572670419486207621442965694205079319172441480920448232840127470321964282081201905714188996459998317503801888689594202055922021154729973848802607363697417887792157984675099539630078260959624203483238660139857363433909737126527995991969968377913168168154428850279651529278107679714002040605674803938561251718357006907984996341976291474044834540269715476228513178020643878047649322579052898467085805286258130005429388560720609747223040631357234936458406575916916916727060124402896700001069081035313852902700415084232336239889386496782194149838027072957176812879001445746227147702348357151905506")
	}

	static [BigNum] cbrt3() {
		return [BigNum]::new("1.4422495703074083823216383107801095883918692534993505775464161945416875968299973398547554797056452566868350808544895499664254239461102597148689501571852372270903320238475984450610855400272600881454988727513673553524678660747156884392233189182017038998238223321296166355085262673491335016654548957881758552741755933631318741467200604638466647569374364197555749424906820810942671235906265763689646373616178216558425874823856595235871903196104071395306028102853508443638035194550133809152223907849897509193948036531196743457062338119411183556576924832001231070159153329300428270666394443820480019012241818057851180278635499201489352352796818010900623683532797037372461456517341535339099046710530415693769030514949589952161665911663338019542272664828143118184417165535766881832140589503272799127928026983572135676304667631409826930968622476494140464484288713308799468418700020456187690275033046203665644407179091196980397474788838026707228447481594820872396116012271067171066612781813201108139530097227226")
	}

	static [BigNum] EulerMascheroniGamma() {
		return [BigNum]::new("0.5772156649015328606065120900824024310421593359399235988057672348848677267776646709369470632917467495146314472498070824809605040144865428362241739976449235362535003337429373377376739427925952582470949160087352039481656708532331517766115286211995015079847937450857057400299213547861466940296043254215190587755352673313992540129674205137541395491116851028079842348775872050384310939973613725530608893312676001724795378367592713515772261027349291394079843010341777177808815495706610750101619166334015227893586796549725203621287922655595366962817638879272680132431010476505963703947394957638906572967929601009015125195950922243501409349871228247949747195646976318506676129063811051824197444867836380861749455169892792301877391072945781554316005002182844096053772434203285478367015177394398700302370339518328690001558193988042707411542227819716523011073565833967348717650491941812300040654693142999297779569303100503086303418569803231083691640025892970890985486825777364288253954925873629596133298574739302")
	}

	static [BigNum] AperyZeta3() {
		return [BigNum]::new("1.2020569031595942853997381615114499907649862923404988817922715553418382057863130901864558736093352581461991577952607194184919959986732832137763968372079001614539417829493600667191915755222424942439615639096641032911590957809655146512799184051057152559880154371097811020398275325667876035223369849416618110570147157786394997375237852779370309560257018531827900030765471075630488433208697115737423807934450316076253177145354444118311781822497185263570918244899879620350833575617202260339378587032813126780799005417734869115253706562370574409662217129026273207323614922429130405285553723410330775777980642420243048828152100091460265382206962715520208227433500101529480119869011762595167636699817183557523488070371955574234729408359520886166620257285375581307928258648728217370556619689895266201877681062920081779233813587682842641243243148028217367450672069350762689530434593937503296636377575062473323992348288310773390527680200757984356793711505090050273660471140085335034364672248565315181177661810922")
	}

	static [BigNum] CatalanG() {
		return [BigNum]::new("0.9159655941772190150546035149323841107741493742816721342664981196217630197762547694793565129261151062485744226191961995790358988033258590594315947374811584069953320287733194605190387274781640878659090247064841521630002287276409423882599577415088163974702524820115607076448838078733704899008647751132259971343407485407553230768565335768095835260219382323950800720680355761048235733942319149829836189977069036404180862179411019175327431499782339761055122477953032487537187866582808236057022559419481809753509711315712615804242723636439850017382875977976530683700929808738874956108936597719409687268444416680462162433986483891628044828150627302274207388431172218272190472255870531908685735423498539498309919115967388464508615152499624237043745177737235177544070853846440132174839299994757244619975496197587064007474870701490937678873045869979860644874974643872062385137123927363049985035392239287879790633644032354784535851927777787270906083031994301332316712476158709792455479119092126201854803963934243")
	}

	static [BigNum] FeigenbaumA() {
		return [BigNum]::new("2.5029078750958928222839028732182157863812713767271499773361920567792354631795902067032996497464338341295952318699958547239421823777854451792728633149933725781121635948795037447812609973805986712397117373289276654044010306698313834600094139322364490657889951220584317250787337746308785342428535198858750004235824691874082042817009017148230518216216194131998560661293827426497098440844701008054549677936760888126446406885181552709324007542506497157047047541993283178364533256241537869395712509706638797949265462313767459189098131167524342211101309131278371609511583412308415037164997020224681219644081216686527458043026245782561067150138521821644953254334987348741335279581535101658360545576351327650181078119483694595748502373982354526256327794753972699020128915166457939420198920248803394051699686551494477396533876979741232354061781989611249409599035312899773361184984737794610842883329383390395090089140863515256268033814146692799133107433497051435452013446434264752001621384610729922641994332772918")
	}

	static [BigNum] FeigenbaumDelta() {
		return [BigNum]::new("4.6692016091029906718532038204662016172581855774757686327456513430041343302113147371386897440239480138171659848551898151344086271420279325223124429888908908599449354632367134115324817142199474556443658237932020095610583305754586176522220703854106467494942849814533917262005687556659523398756038256372256480040951071283890611844702775854285419801113440175002428585382498335715522052236087250291678860362674527213399057131606875345083433934446103706309452019115876972432273589838903794946257251289097948986768334611626889116563123474460575179539122045562472807095202198199094558581946136877445617396074115614074243754435499204869180982648652368438702799649017397793425134723808737136211601860128186102056381818354097598477964173900328936171432159878240789776614391395764037760537119096932066998361984288981837003229412030210655743295550388845849737034727532121925706958414074661841981961006129640161487712944415901405467941800198133253378592493365883070459999938375411726563553016862529032210862320550634")
	}



	#endregion Math Constants



	#region Physics Constants

	static [BigNum] c() {
		#Expressed in Meters per Seconds
		#Exact value
		return [BigNum]::new("299792458")
	}

	static [BigNum] Plank_h() {
		#Expressed in Joules . Seconds
		#Exact value
		return [BigNum]::new("0.000000000000000000000000000000000662607015")
	}

	static [BigNum] Plank_Reduced_h() {
		#Expressed in Joules . Seconds
		#Aproximate value
		return [BigNum]::new("0.0000000000000000000000000000000001054571817646156391262428003302281")
	}

	static [BigNum] Boltzmann_k() {
		#Expressed in Joules per Kelvin
		#Exact value
		return [BigNum]::new("0.00000000000000000000001380649")
	}

	static [BigNum] G() {
		#Expressed in Meters^3 per Kilogrammes per Seconds^2
		#Aproximate value
		return [BigNum]::new("0.0000000000667430")
	}

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
