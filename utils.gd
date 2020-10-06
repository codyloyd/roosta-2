extends Node

func random_from_array(array):
	var array_copy = [] + array
	array_copy.shuffle()
	return array_copy[0]


func array_includes(array, item):
	for x in array:
		if x == item:
			return true

	return false

func array_find_func(array, ref):
	for x in array:
		if ref.call_func(x):
			return x

	return false

func array_filter(array, ref):
	var new_array = []
	for x in array:
		if ref.call_func(x):
			new_array.append(x)

	return new_array

