# matlabTableAgent
Allowing method chaining of tablular class (and of course table and timetable subclass) in matlab.  
You can just replace your yourMatlabInstallDirectory\toolbox\matlab\datatypes\tabular\@tabular\dotParenReference.m with the file of the same name in this repository.  
Please do not forget to backup your original file before substituting. If you do forget, the dotParenReference.m.bak is for you.  
This method has only been tested on Matlab R2022a and R2022b. And I do not sure whether it works on other version.  
This is only a simple file modification. The code hints, code completion and error information is not available now. （If you get error like "Unrecognized table variable name", it may stem from a misused method.)  
I admit that it may not perform well in terms of portability and safety because of the demand to replace original matlab file (which is a serious violation of OCP principle) and the use of eval function.  
However, if you prefer object-oriented programming and method chaining, I still recommend using it.  
Currently, the only known function that cannot be used as a method is summary.  
  
本存储库可以帮助您在matlab中实现对tabular类（table和timetable子类）的方法链式调用。  
您只需将您的matlab安装目录\toolbox\MATLAB\datatypes\tabular\@tabular\dotParenReference.m替换为此存储库中的同名文件即可。  
请不要忘记在替换之前备份您的原始文件。如果你不慎忘了，你可以取走这个存储库中的dotParenReference.m.bak文件。  
该方法仅在R2022a和R2022b上进行了测试。我不确定它是否适用于其他版本。  
这只是对原始文件的简单修改。代码提示、代码补全和报错信息现在还不可用。（如果您得到“无法识别表变量名称”错误，这可能是由于您错误调用了某些方法所致。）  
我承认他在可移植性和安全性上可能表现不佳，因为需要修改原始matlab文件（这严重违背了开闭原则）以及运用了eval函数。  
尽管如此，如果你喜欢面向对象编程和方法链式调用的话，我还是推荐您使用它。  
目前已知不能用作方法的函数只有summary。  
