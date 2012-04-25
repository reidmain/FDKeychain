static inline BOOL FDIsNull(id object)
{
	BOOL isNull = NO;
	
	if (object == nil 
		|| object == [NSNull null])
	{
		isNull = YES;
	}
	
	return isNull;
}

static inline BOOL FDIsEmpty(id object)
{
	BOOL isEmpty = NO;
	
	if (FDIsNull(object) == YES 
		|| ([object respondsToSelector: @selector(length)] 
			&& [object length] == 0) 
		|| ([object respondsToSelector: @selector(count)] 
			&& [object count] == 0))
	{
		isEmpty = YES;
	}
	
	return isEmpty;
}