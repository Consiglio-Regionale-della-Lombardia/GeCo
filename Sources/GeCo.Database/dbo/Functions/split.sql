CREATE function split(
 @myString nvarchar (4000),
 @Delimiter nvarchar (10)
 )
returns @ValueTable table ([Value] nvarchar(4000))
begin
 declare @NextString nvarchar(4000)
 declare @Pos int
 declare @NextPos int
 declare @CommaCheck nvarchar(1)
 --Initialize
 set @NextString = ''
 set @CommaCheck = right(@myString,1) 
 --Check for trailing Comma, if not exists, INSERT
 --if (@CommaCheck <> @Delimiter )
 set @myString = @myString + @Delimiter
 
 --Get position of first Comma
 set @Pos = charindex(@Delimiter,@myString)
 set @NextPos = 1
 
 --Loop while there is still a comma in the String of levels
 while (@pos <>  0)  
 begin
  set @NextString = substring(@myString,1,@Pos - 1)
  insert into @ValueTable ( [Value]) Values (@NextString)
  set @myString = substring(@myString,@pos +1,len(@myString))
 
  set @NextPos = @Pos
  set @pos  = charindex(@Delimiter,@myString)
 end
 return
end
