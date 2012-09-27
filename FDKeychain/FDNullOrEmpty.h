static inline BOOL FDIsNull(id object)
{
	// Check if the object is nil or the NSNull object.
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
	// Check if the object is null or if the object responds to the length or count selector and is zero.
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