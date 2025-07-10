
#region Classes

class BigNum : System.IComparable {

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
		$this.Init($newVal,$newShift,$false,[BigNum]::defaultMaxDecimalResolution)
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

		while (($tmpCount -gt 0) -and ($tmpString[-1] -eq '0')) {
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

	[bool] isNegative(){
		return $this.negativeFlag
	}

	#endregion Accessors



	#region Extractors

	hidden [void] extractFromDouble([double]$doubleVal) {
		$tmpNegativeFlag = $false
		$tmpIntegerVal = [System.Numerics.BigInteger]::Parse(0)
		$tmpShiftVal = [System.Numerics.BigInteger]::Parse(0)

		$strNewVal = [math]::Abs($doubleVal).ToString("F",[CultureInfo]::InvariantCulture).Split('.')

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

		$this.Init($tmpIntegerVal,$tmpShiftVal,$tmpNegativeFlag,[BigNum]::defaultMaxDecimalResolution)
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

		$this.Init($tmpIntegerVal,$tmpShiftVal,$tmpNegativeFlag,[BigNum]::defaultMaxDecimalResolution)
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

		$cleanStr = $stringVal -replace ('[\.|\'+$deciChar+']'), '.'
		$cleanStr = $cleanStr -replace ('[^0-9\.]'), ''

		if ($cleanStr.LastIndexOf('.') -ne -1) {
			$tmpShiftVal = $cleanStr.Length - ($cleanStr.LastIndexOf('.') + 1)
		}

		$intStr = $cleanStr -replace ('[^0-9]'), ''
		$tmpIntegerVal = [System.Numerics.BigInteger]::Parse($intStr)

		$this.Init($tmpIntegerVal,$tmpShiftVal,$tmpNegativeFlag,[BigNum]::defaultMaxDecimalResolution)
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
		if ($other == $null) {return 1}

		if ($this.Equals($other)) { return 0 }

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



	#region Base Operators

	static [BigNum] op_Addition([BigNum] $a, [BigNum] $b) {
		[System.Numerics.BigInteger]$tmpA = $a.integerVal
	  	[System.Numerics.BigInteger]$tmpB = $b.integerVal
	  
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

		return [BigNum]::new($tmpA + $tmpB,[System.Numerics.BigInteger]::Max($a.shiftVal,$b.shiftVal),[System.Numerics.BigInteger]::Max($a.maxDecimalResolution,$b.maxDecimalResolution))
	}

	static [BigNum] op_Subtraction([BigNum] $a, [BigNum] $b) {
		[System.Numerics.BigInteger]$tmpA = $a.integerVal
	  	[System.Numerics.BigInteger]$tmpB = $b.integerVal
	  
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

		return [BigNum]::new($tmpA - $tmpB,[System.Numerics.BigInteger]::Max($a.shiftVal,$b.shiftVal),[System.Numerics.BigInteger]::Max($a.maxDecimalResolution,$b.maxDecimalResolution))
	}

	static [BigNum] op_Multiply([BigNum] $a, [BigNum] $b) {
		[System.Numerics.BigInteger]$tmpA = $a.integerVal
	  	[System.Numerics.BigInteger]$tmpB = $b.integerVal
	  
	  	if ($a.negativeFlag) { $tmpA *= -1 }
	  	if ($b.negativeFlag) { $tmpB *= -1 }

		return [BigNum]::new($tmpA * $tmpB,$a.shiftVal + $b.shiftVal,$a.maxDecimalResolution + $b.maxDecimalResolution)
	}

	static [BigNum] op_Division([BigNum] $a, [BigNum] $b) {
		[System.Numerics.BigInteger]$tmpA = $a.integerVal
	  	[System.Numerics.BigInteger]$tmpB = $b.integerVal
		[System.Numerics.BigInteger]$newDecimalResolution = [System.Numerics.BigInteger]::Max($a.maxDecimalResolution,$b.maxDecimalResolution)
		[System.Numerics.BigInteger]$newShiftVal = $a.shiftVal + $newDecimalResolution - $b.shiftVal

	  	if ($a.negativeFlag) { $tmpA *= -1 }
	  	if ($b.negativeFlag) { $tmpB *= -1 }

		$tmpA *= [System.Numerics.BigInteger]::Pow(10,$newDecimalResolution + $a.shiftVal + $b.shiftVal)
		$tmpB *= [System.Numerics.BigInteger]::Pow(10,$a.shiftVal + $b.shiftVal)

		return [BigNum]::new($tmpA / $tmpB,$newShiftVal,$newDecimalResolution)
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

	# static [BigNum] Pow([BigNum] $value, [int] $exponent) {
	# 	if($exponent -lt [Int32]::MaxValue ) {
	# 		return [BigNum]::new( [System.Numerics.BigInteger]::Pow($this.integerVal,$exponent.ToInt32()) )
	# 	}
	# 	[System.Numerics.BigInteger] $result = $this.integerVal
	# 	for([BigNum] $tempExp = $exponent - 1 ; $tempExp -gt 0 ; $tempExp = $tempExp - 1 ) {
	# 		$result = $result * $this.integerVal
	# 	}
	# 	return [BigNum]::new([System.Numerics.BigInteger]::ModPow($this.integerVal,$exponent.val,$modulus.val))
	# }

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
}

#endregion Classes



function New-BigNum {
	[CmdletBinding()]
	param (
		[object] $val=[int]::Parse(0)
	)

	return New-Object -TypeName "BigNum" $val
}
