extends Control

func cost():
	return 30

func name_returner():
	return "dagger"

func stat_and_value_returner(query):
	if query == "stat":
		return "ad"
	if query == "value":
		return 10
