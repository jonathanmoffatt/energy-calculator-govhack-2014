# Basis for calculation
# Energy rating is based on 52 loads per year
share.GetDryerCostAnnually = (rate, kWh52Load, ActualLoad) ->
	rate * kWh52Load * (ActualLoad / 52)

# Energy rating is based on 365 loads per year
share.GetWashingMachineCostAnnually = (rate, kWh365Loads, ActualLoad) ->
	rate * kWh365Loads * (ActualLoad / 365)

#Energy rating is based on 10 hours of TV per day
share.GetTVCostAnnually = (rate, kWH10HrsDay, ActualHours) ->
	rate * kWH10HrsDay * (parseFloat(ActualHours / 10))

#Energy rating is based on 365 washes per year
share.GetDishwasherCostAnnually = (rate, kWh365Loads, ActualLoad) ->
	rate * kWh365Loads * (ActualLoad / 365)

#Energy rating is based on 200 cold and hot hours per year
share.GetAirConCostAnnually = (rate, coolInput, coolHours, hotInput, hotHours) ->
	(rate * coolInput * (coolHours/200)) + (rate * hotInput * (hotHours/200))






