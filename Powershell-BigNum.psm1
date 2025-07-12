
#region Classes

class BigNum : System.IComparable, System.IEquatable[Object] {

	hidden [System.Numerics.BigInteger] $integerVal
	hidden [System.Numerics.BigInteger] $shiftVal
	hidden [bool] $negativeFlag
	hidden [System.Numerics.BigInteger] $maxDecimalResolution
	hidden static [System.Numerics.BigInteger] $defaultMaxDecimalResolution = 100


	
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
			$shiftFactor = [System.Numerics.BigInteger]::Pow(10,$shift*(-1))
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
			$tmpIntegerVal *= [System.Numerics.BigInteger]::Pow(10,$tmpShiftVal)
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
			$tmpIntegerVal *= [System.Numerics.BigInteger]::Pow(10,$tmpShiftVal)
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

		if (($this.integerVal -eq $other.integerVal) -and ($this.shiftVal -eq $other.shiftVal) -and ($this.negativeFlag -eq $other.negativeFlag)) { return 0 }

		[System.Numerics.BigInteger]$tmpThis = $this.integerVal
		[System.Numerics.BigInteger]$tmpOther = $other.integerVal
		
		if ($this.negativeFlag) { $tmpThis *= -1 }
		if ($other.negativeFlag) { $tmpOther *= -1 }

		if ($this.shiftVal -ne $other.shiftVal) {
			if ($this.shiftVal -gt $other.shiftVal) {
				$shiftDifference = $this.shiftVal - $other.shiftVal
				$shiftFactor = [System.Numerics.BigInteger]::Pow(10,$shiftDifference)
				$tmpOther *= $shiftFactor
			}else{
				$shiftDifference = $other.shiftVal - $this.shiftVal
				$shiftFactor = [System.Numerics.BigInteger]::Pow(10,$shiftDifference)
				$tmpThis *= $shiftFactor
			}
		}
		if ($tmpThis -lt $tmpOther) {return -1 }

		return 1 # -gt
    }

	[int] GetHashCode() {
		return $this.ToString().GetHashCode()
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
				$shiftFactor = [System.Numerics.BigInteger]::Pow(10,$shiftDifference)
				$tmpB *= $shiftFactor
			}else{
				$shiftDifference = $b.shiftVal - $a.shiftVal
				$shiftFactor = [System.Numerics.BigInteger]::Pow(10,$shiftDifference)
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
				$shiftFactor = [System.Numerics.BigInteger]::Pow(10,$shiftDifference)
				$tmpB *= $shiftFactor
			}else{
				$shiftDifference = $b.shiftVal - $a.shiftVal
				$shiftFactor = [System.Numerics.BigInteger]::Pow(10,$shiftDifference)
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

		$tmpA *= [System.Numerics.BigInteger]::Pow(10,$newDecimalResolution + $b.shiftVal)

		return [BigNum]::new($tmpA / $tmpB,$newDecimalResolution + $a.shiftVal,$newDecimalResolution)
	}

	static [BigNum] op_Modulus([BigNum] $a, [System.Numerics.BigInteger] $b) {
		[System.Numerics.BigInteger]$tmpA = $a.Int()
		[System.Numerics.BigInteger]$tmpModed = $tmpA % $b

		[BigNum]$tmpResult = $a - [BigNum]$tmpA
		[BigNum]$tmpResult += [BigNum]::new($tmpModed)

		return [BigNum]::new($tmpResult,$a.getMaxDecimalResolution())
	}

	static [BigNum] op_LeftShift([BigNum] $a, [System.Numerics.BigInteger] $b) {
		[System.Numerics.BigInteger]$tmpA = $a.integerVal
		[System.Numerics.BigInteger]$newShiftVal = $a.shiftVal - $b

		if ($newShiftVal -lt 0) {
			$tmpA *= [System.Numerics.BigInteger]::Pow(10,-$newShiftVal)
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

	static [BigNum] Log([BigNum] $value) {
		return [BigNum]::Log($value,300)
	}

	static [BigNum] Log([BigNum] $value,[System.Numerics.BigInteger] $numTaylor) {
		# Trap illegal values
		if ($value -le 0) {
			throw "[BigNum]::Log() function is not defined for zero nor negative numbers"
		}
		
		[BigNum] $tmpVal = [BigNum]::new($value).ChangeResolution([BigNum]::e().getMaxDecimalResolution())
		[BigNum] $tmpOne = [BigNum]::new("1.0")
		[BigNum] $tmpQuarter = [BigNum]::new("0.25")
		[System.Numerics.BigInteger] $powerAdjust = [System.Numerics.BigInteger]::Parse(0);
		[System.Numerics.BigInteger] $TAYLOR_ITERATIONS = [System.Numerics.BigInteger]::Parse($numTaylor)

		# Confine x to a sensible range
		while ($tmpVal -gt $tmpOne) {
			$tmpVal /= [BigNum]::e()
			$powerAdjust += 1
		}
		while ($tmpVal -lt $tmpQuarter) {
			$tmpVal *= [BigNum]::e()
			$powerAdjust -= 1
		}
		
		# Now use the Taylor series to calculate the logarithm
		$tmpVal -= 1
		[BigNum] $tmpT = [BigNum]::new(0).ChangeResolution($tmpVal.maxDecimalResolution)
		[BigNum] $tmpS = [BigNum]::new(1).ChangeResolution($tmpVal.maxDecimalResolution)
		[BigNum] $tmpZ = [BigNum]::new($tmpVal).ChangeResolution($tmpVal.maxDecimalResolution)

		for ([BigNum]$k = 1; $k -le $TAYLOR_ITERATIONS; $k += 1) {
			$tmpT += $tmpZ * $tmpS / $k
			$tmpZ *= $tmpVal
			$tmpS *= -1
		}
		
		# Combine the result with the power_adjust value and return
		return [BigNum]::new($tmpT+$powerAdjust,$value.maxDecimalResolution)
	}

	static [BigNum] Exp([BigNum] $value) {
		return [BigNum]::Exp($value,300)
	}

	static [BigNum] Exp([BigNum] $exponent, [System.Numerics.BigInteger] $numTaylor) {
		# Initialize terms
		[BigNum] $result = [BigNum]::new(1).ChangeResolution($exponent.maxDecimalResolution)  # Sum accumulator
		[BigNum] $term = [BigNum]::new(1).ChangeResolution($exponent.maxDecimalResolution)    # Current term (starts at 1)
		[BigNum] $factorial = [BigNum]::new(1).ChangeResolution($exponent.maxDecimalResolution) # Current factorial value

		for ([System.Numerics.BigInteger] $n = 1; $n -le $numTaylor; $n += 1) {
			$term *= $exponent
			$factorial *= [BigNum]::new($n)
			$result += $term / $factorial
		}

		return $result
	}

	static [BigNum] Pow([BigNum] $value, [BigNum] $exponent) {
		if($exponent.IsInteger()) {
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
		return [BigNum]::new([BigNum]::Exp(($exponent*([BigNum]::Log($value)))),$value.maxDecimalResolution)
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
					$newVal = [System.Numerics.BigInteger]::Pow(10,$toRound - $this.shiftVal)
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
					$newVal = [System.Numerics.BigInteger]::Pow(10,$toRound - $this.shiftVal)
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
					$newVal = [System.Numerics.BigInteger]::Pow(10,$toRound - $this.shiftVal)
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
					$tmpVal *= [System.Numerics.BigInteger]::Pow(10,-$decimals)
				}
			}else{
				$tmpShift = [System.Numerics.BigInteger]::Parse(0)
				$tmpVal = [System.Numerics.BigInteger]::Parse(0)
				$tmpSign = $false
			}
		}

		return [BigNum]::new($tmpVal,$tmpShift,$tmpSign,$tmpResolution)
	}

	#endregion Methods



	#region Math Constants

	static [BigNum] Pi() {
		return [BigNum]::new("3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348253421170679821480865132823066470938446095505822317253594081284811174502841027019385211055596446229489549303819644288109756659334461284756482337867831652712019091456485669234603486104543266482133936072602491412737245870066063155881748815209209628292540917153643678925903600113305305488204665213841469519415116094330572703657595919530921861173819326117931051185480744623799627495673518857527248912279381830119491298336733624406566430860213949463952247371907021798609437027705392171762931767523846748184676694051320005681271452635608277857713427577896091736371787214684409012249534301465495853710507922796892589235420199561121290219608640344181598136297747713099605187072113499999983729780499510597317328160963185950244594553469083026425223082533446850352619311881710100031378387528865875332083814206171776691473035982534904287554687311595628638823537875937519577818577805321712268066130019278766111959092164201989")
	}

	static [BigNum] Tau() {
		return [BigNum]::new("6.2831853071795864769252867665590057683943387987502116419498891846156328125724179972560696506842341359642961730265646132941876892191011644634507188162569622349005682054038770422111192892458979098607639288576219513318668922569512964675735663305424038182912971338469206972209086532964267872145204982825474491740132126311763497630418419256585081834307287357851807200226610610976409330427682939038830232188661145407315191839061843722347638652235862102370961489247599254991347037715054497824558763660238982596673467248813132861720427898927904494743814043597218874055410784343525863535047693496369353388102640011362542905271216555715426855155792183472743574429368818024499068602930991707421015845593785178470840399122242580439217280688363196272595495426199210374144226999999967459560999021194634656321926371900489189106938166052850446165066893700705238623763420200062756775057731750664167628412343553382946071965069808575109374623191257277647075751875039155637155610643424536132260038557532223918184328403978")
	}

	static [BigNum] e() {
		# 10000 decimal long
		# return [BigNum]::new("2.718281828459045235360287471352662497757247093699959574966967627724076630353547594571382178525166427427466391932003059921817413596629043572900334295260595630738132328627943490763233829880753195251019011573834187930702154089149934884167509244761460668082264800168477411853742345442437107539077744992069551702761838606261331384583000752044933826560297606737113200709328709127443747047230696977209310141692836819025515108657463772111252389784425056953696770785449969967946864454905987931636889230098793127736178215424999229576351482208269895193668033182528869398496465105820939239829488793320362509443117301238197068416140397019837679320683282376464804295311802328782509819455815301756717361332069811250996181881593041690351598888519345807273866738589422879228499892086805825749279610484198444363463244968487560233624827041978623209002160990235304369941849146314093431738143640546253152096183690888707016768396424378140592714563549061303107208510383750510115747704171898610687396965521267154688957035035402123407849819334321068170121005627880235193033224745015853904730419957777093503660416997329725088687696640355570716226844716256079882651787134195124665201030592123667719432527867539855894489697096409754591856956380236370162112047742722836489613422516445078182442352948636372141740238893441247963574370263755294448337998016125492278509257782562092622648326277933386566481627725164019105900491644998289315056604725802778631864155195653244258698294695930801915298721172556347546396447910145904090586298496791287406870504895858671747985466775757320568128845920541334053922000113786300945560688166740016984205580403363795376452030402432256613527836951177883863874439662532249850654995886234281899707733276171783928034946501434558897071942586398772754710962953741521115136835062752602326484728703920764310059584116612054529703023647254929666938115137322753645098889031360205724817658511806303644281231496550704751025446501172721155519486685080036853228183152196003735625279449515828418829478761085263981395599006737648292244375287184624578036192981971399147564488262603903381441823262515097482798777996437308997038886778227138360577297882412561190717663946507063304527954661855096666185664709711344474016070462621568071748187784437143698821855967095910259686200235371858874856965220005031173439207321139080329363447972735595527734907178379342163701205005451326383544000186323991490705479778056697853358048966906295119432473099587655236812859041383241160722602998330535370876138939639177957454016137223618789365260538155841587186925538606164779834025435128439612946035291332594279490433729908573158029095863138268329147711639633709240031689458636060645845925126994655724839186564209752685082307544254599376917041977780085362730941710163434907696423722294352366125572508814779223151974778060569672538017180776360346245927877846585065605078084421152969752189087401966090665180351650179250461950136658543663271254963990854914420001457476081930221206602433009641270489439039717719518069908699860663658323227870937650226014929101151717763594460202324930028040186772391028809786660565118326004368850881715723866984224220102495055188169480322100251542649463981287367765892768816359831247788652014117411091360116499507662907794364600585194199856016264790761532103872755712699251827568798930276176114616254935649590379804583818232336861201624373656984670378585330527583333793990752166069238053369887956513728559388349989470741618155012539706464817194670834819721448889879067650379590366967249499254527903372963616265897603949857674139735944102374432970935547798262961459144293645142861715858733974679189757121195618738578364475844842355558105002561149239151889309946342841393608038309166281881150371528496705974162562823609216807515017772538740256425347087908913729172282861151591568372524163077225440633787593105982676094420326192428531701878177296023541306067213604600038966109364709514141718577701418060644363681546444005331608778314317444081194942297559931401188868331483280270655383300469329011574414756313999722170380461709289457909627166226074071874997535921275608441473782330327033016823719364800217328573493594756433412994302485023573221459784328264142168487872167336701061509424345698440187331281010794512722373788612605816566805371439612788873252737389039289050686532413806279602593038772769778379286840932536588073398845721874602100531148335132385004782716937621800490479559795929059165547050577751430817511269898518840871856402603530558373783242292418562564425502267215598027401261797192804713960068916382866527700975276706977703643926022437284184088325184877047263844037953016690546593746161932384036389313136432713768884102681121989127522305625675625470172508634976536728860596675274086862740791285657699631378975303466061666980421826772456053066077389962421834085988207186468262321508028828635974683965435885668550377313129658797581050121491620765676995065971534476347032085321560367482860837865680307306265763346977429563464371670939719306087696349532884683361303882943104080029687386911706666614680001512114344225602387447432525076938707777519329994213727721125884360871583483562696166198057252661220679754062106208064988291845439530152998209250300549825704339055357016865312052649561485724925738620691740369521353373253166634546658859728665945113644137033139367211856955395210845840724432383558606310680696492485123263269951460359603729725319836842336390463213671011619282171115028280160448805880238203198149309636959673583274202498824568494127386056649135252670604623445054922758115170931492187959271800194096886698683703730220047531433818109270803001720593553052070070607223399946399057131158709963577735902719628506114651483752620956534671329002599439766311454590268589897911583709341937044115512192011716488056694593813118384376562062784631049034629395002945834116482411496975832601180073169943739350696629571241027323913874175492307186245454322203955273529524024590380574450289224688628533654221381572213116328811205214648980518009202471939171055539011394331668151582884368760696110250517100739276238555338627255353883096067164466237092264680967125406186950214317621166814009759528149390722260111268115310838731761732323526360583817315103459573653822353499293582283685100781088463434998351840445170427018938199424341009057537625776757111809008816418331920196262341628816652137471732547772778348877436651882875215668571950637193656539038944936642176400312152787022236646363575550356557694888654950027085392361710550213114741374410613444554419210133617299628569489919336918472947858072915608851039678195942983318648075608367955149663644896559294818785178403877332624705194505041984774201418394773120281588684570729054405751060128525805659470304683634459265255213700806875200959345360731622611872817392807462309468536782310609792159936001994623799343421068781349734695924646975250624695861690917857397659519939299399556754271465491045686070209901260681870498417807917392407194599632306025470790177452751318680998228473086076653686685551646770291133682756310722334672611370549079536583453863719623585631261838715677411873852772292259474337378569553845624680101390572787101651296663676445187246565373040244368414081448873295784734849000301947788802046032466084287535184836495919508288832320652212810419044804724794929134228495197002260131043006241071797150279343326340799596053144605323048852897291765987601666781193793237245385720960758227717848336161358261289622611812945592746276713779448758675365754486140761193112595851265575973457301533364263076798544338576171533346232527057200530398828949903425956623297578248873502925916682589445689465599265845476269452878051650172067478541788798227680653665064191097343452887833862172615626958265447820567298775642632532159429441803994321700009054265076309558846589517170914760743713689331946909098190450129030709956622662030318264936573369841955577696378762491885286568660760056602560544571133728684020557441603083705231224258722343885412317948138855007568938112493538631863528708379984569261998179452336408742959118074745341955142035172618420084550917084568236820089773945584267921427347756087964427920270831215015640634134161716644806981548376449157390012121704154787259199894382536495051477137939914720521952907939613762110723849429061635760459623125350606853765142311534966568371511660422079639446662116325515772907097847315627827759878813649195125748332879377157145909106484164267830994972367442017586226940215940792448054125536043131799269673915754241929660731239376354213923061787675395871143610408940996608947141834069836299367536262154524729846421375289107988438130609555262272083751862983706678722443019579379378607210725427728907173285487437435578196651171661833088112912024520404868220007234403502544820283425418788465360259150644527165770004452109773558589762265548494162171498953238342160011406295071849042778925855274303522139683567901807640604213830730877446017084268827226117718084266433365178000217190344923426426629226145600433738386833555534345300426481847398921562708609565062934040526494324426144566592129122564889356965500915430642613425266847259491431423939884543248632746184284665598533231221046625989014171210344608427161661900125719587079321756969854401339762209674945418540711844643394699016269835160784892451405894094639526780735457970030705116368251948770118976400282764841416058720618418529718915401968825328930914966534575357142731848201638464483249903788606900807270932767312758196656394114896171683298045513972950668760474091542042842999354102582911350224169076943166857424252250902693903481485645130306992519959043638402842926741257342244776558417788617173726546208549829449894678735092958165263207225899236876845701782303809656788311228930580914057261086588484587310165815116753332767488701482916741970151255978257270740643180860142814902414678047232759768426963393577354293018673943971638861176420900406866339885684168100387238921448317607011668450388721236436704331409115573328018297798873659091665961240202177855885487617616198937079438005666336488436508914480557103976521469602766258359905198704230017946553679")
		
		# 2000 decimal long
		# return [BigNum]::new("2.71828182845904523536028747135266249775724709369995957496696762772407663035354759457138217852516642742746639193200305992181741359662904357290033429526059563073813232862794349076323382988075319525101901157383418793070215408914993488416750924476146066808226480016847741185374234544243710753907774499206955170276183860626133138458300075204493382656029760673711320070932870912744374704723069697720931014169283681902551510865746377211125238978442505695369677078544996996794686445490598793163688923009879312773617821542499922957635148220826989519366803318252886939849646510582093923982948879332036250944311730123819706841614039701983767932068328237646480429531180232878250981945581530175671736133206981125099618188159304169035159888851934580727386673858942287922849989208680582574927961048419844436346324496848756023362482704197862320900216099023530436994184914631409343173814364054625315209618369088870701676839642437814059271456354906130310720851038375051011574770417189861068739696552126715468895703503540212340784981933432106817012100562788023519303322474501585390473041995777709350366041699732972508868769664035557071622684471625607988265178713419512466520103059212366771943252786753985589448969709640975459185695638023637016211204774272283648961342251644507818244235294863637214174023889344124796357437026375529444833799801612549227850925778256209262264832627793338656648162772516401910590049164499828931505660472580277863186415519565324425869829469593080191529872117255634754639644791014590409058629849679128740687050489585867174798546677575732056812884592054133405392200011378630094556068816674001698420558040336379537645203040243225661352783695117788386387443966253224985065499588623428189970773327617178392803494650143455889707194258639877275471096295374152111513683506275260232648472870392076431005958411661205452970302364725492966693811513732275364509888903136020572481765851180630364428123149655070475102544650117272115551948668508003685322818315219600373562527944951582841882947876108526398139")
		
		# 1000 decimal long
		return [BigNum]::new("2.7182818284590452353602874713526624977572470936999595749669676277240766303535475945713821785251664274274663919320030599218174135966290435729003342952605956307381323286279434907632338298807531952510190115738341879307021540891499348841675092447614606680822648001684774118537423454424371075390777449920695517027618386062613313845830007520449338265602976067371132007093287091274437470472306969772093101416928368190255151086574637721112523897844250569536967707854499699679468644549059879316368892300987931277361782154249992295763514822082698951936680331825288693984964651058209392398294887933203625094431173012381970684161403970198376793206832823764648042953118023287825098194558153017567173613320698112509961818815930416903515988885193458072738667385894228792284998920868058257492796104841984443634632449684875602336248270419786232090021609902353043699418491463140934317381436405462531520961836908887070167683964243781405927145635490613031072085103837505101157477041718986106873969655212671546889570350354")
	}

	static [BigNum] phi() {
		return [BigNum]::new("1.6180339887498948482045868343656381177203091798057628621354486227052604628189024497072072041893911374847540880753868917521266338622235369317931800607667263544333890865959395829056383226613199282902678806752087668925017116962070322210432162695486262963136144381497587012203408058879544547492461856953648644492410443207713449470495658467885098743394422125448770664780915884607499887124007652170575179788341662562494075890697040002812104276217711177780531531714101170466659914669798731761356006708748071013179523689427521948435305678300228785699782977834784587822891109762500302696156170025046433824377648610283831268330372429267526311653392473167111211588186385133162038400522216579128667529465490681131715993432359734949850904094762132229810172610705961164562990981629055520852479035240602017279974717534277759277862561943208275051312181562855122248093947123414517022373580577278616008688382952304592647878017889921990270776903895321968198615143780314997411069260886742962267575605231727775203536139362")
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
