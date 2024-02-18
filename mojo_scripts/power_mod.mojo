fn number_to_binary_string(owned n: Int) -> String:
	var binary = String("")
	@unroll(1)
	while n > 0:
		binary = String(n%2) + binary
		n = n//2
	return binary

fn power_mod(a: Int, owned b:Int, m: Int)raises -> Int:
	var z = 1
	let binary = number_to_binary_string(b) 

	@unroll(1)
	for i in range(len(binary)):
		if binary[i] == "1": z = (z**2 * a)%m
		else: z = (z**2)%m
	return z

fn main()raises:
	print_no_newline('a:', 552, 'b:', 79, 'm:', 3337, '=>')
	print(power_mod(552,79,3337))
