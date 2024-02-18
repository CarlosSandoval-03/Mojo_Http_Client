from python import Python

fn power_mod(a: Int, owned b:Int, m: Int)raises -> Int:
	var z = 1
	let bin = Python.import_module('builtins').bin
	let builtin_len = Python.import_module('builtins').len
	let binary = bin(b).replace('0b', '')

	@unroll(1)
	for i in range(builtin_len(binary).to_float64().to_int()):
		if binary[i] == "1": z = (z**2 * a)%m
		else: z = (z**2)%m
	return z

fn main()raises:
	print_no_newline('a:', 552, 'b:', 79, 'm:', 3337, '=>')
	print(power_mod(552,79,3337))
