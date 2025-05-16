on fibonacci(n)
	if n ² 2 then
		return 1
	else
		return fibonacci(n - 1) + fibonacci(n - 2)
	end if
end fibonacci


-- ???:
set result to fibonacci(5)
log result

