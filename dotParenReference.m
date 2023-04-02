function b = dotParenReference(t,varName,rowIndices,colIndices,varargin)
%DOTPARENREFERENCE Dot-parens subscripted reference for a table.

% This function is for internal use only and will change in a
% future release.  Do not use this function.

%   Copyright 2015-2019 The MathWorks, Inc.

import matlab.internal.datatypes.isColon
import matlab.internal.datatypes.isScalarInt
import matlab.internal.datatypes.tryThrowIllegalDotMethodError
import matlab.lang.correction.ReplaceIdentifierCorrection

% dotParenReference is called directly for RHS subscripting expressions such as
%    t.Var(rowindices) or t.Var(rowindices,...)
%    t.Var(rownames)   or t.Var(rownames,...)
% but not (yet) for dynamic field references. This method is also called directly
% when there is deeper subscripting
%    t.Var(...)[anything else]
% where [anything else] is handled afterwards by the caller (assuming it
% is not illegal to begin with:"()-indexing must appear last"). With parens
% as the last level of subscripting, no need to worry about varargout.

% Translate variable (column) name into an index. Avoid overhead of
% t.varDim.subs2inds in this simple case.
if isnumeric(varName)
    % Allow t.(i) where i is an integer
    varIndex = varName;
    if ~isScalarInt(varIndex,1)
        error(message('MATLAB:table:IllegalVarIndex'));
    elseif varIndex > t.varDim.length
        error(message('MATLAB:table:VarIndexOutOfRange'));
    end
    % Allow t.(i) where i is an integer
    varIndex = varName;
elseif ischar(varName) && (isrow(varName) || isequal(varName,'')) % isCharString(varName)
    varIndex = find(matches(t.varDim.labels,varName));
    if isempty(varIndex)
        if matches(varName,t.metaDim.labels{1})
            % If it's the row dimension name, index into the row labels
            varIndex = 0;
        elseif matches(varName,t.metaDim.labels{2})
            % If it's the vars dimension name, subscripting into that is not supported,
            % must use explicit braces for that.
            error(message('MATLAB:table:NestedSubscriptingWithDotVariables',t.metaDim.labels{2}));
        
        else
            % If there's no such var, it may be a reference to a property, but
            % without the '.Properties'. Give a helpful error message. Neither
            % t.Properties or t.Properties.PropName end up here, those go to
            % subsrefDot.
            match = find(matches(t.propertyNames,varName,"IgnoreCase",true),1);
            if ~isempty(match)
                match = t.propertyNames{match};
                if matches(varName,match) % a valid property name
                    throw(MException(message('MATLAB:table:IllegalPropertyReference',varName)) ...
                        .addCorrection(ReplaceIdentifierCorrection(varName,append('Properties.',match))));
                else % a property name, but with wrong case
                    throw(MException(message('MATLAB:table:IllegalPropertyReferenceCase',varName,match)) ...
                        .addCorrection(ReplaceIdentifierCorrection(varName,append('Properties.',match))));
                end
            else
                match = matches(t.varDim.labels,varName,'IgnoreCase',true);
                if any(match) % an existing variable name
                    match = t.varDim.labels{match};
                    throw(MException(message('MATLAB:table:UnrecognizedVarNameCase',varName,match)) ...
                        .addCorrection(ReplaceIdentifierCorrection(varName,match)));
                elseif matches(varName,t.metaDim.labels{1},'IgnoreCase',true) % the row dimension name
                    throw(MException(message('MATLAB:table:RowDimNameCase',varName,t.metaDim.labels{1})) ...
                    	.addCorrection(ReplaceIdentifierCorrection(varName,t.metaDim.labels{1})));
                elseif matches(t.defaultDimNames{1},varName) % trying to access row labels by default name
                    throw(t.throwSubclassSpecificError('RowDimNameNondefault',varName,t.metaDim.labels{1}) ...
                    	.addCorrection(ReplaceIdentifierCorrection(varName,t.metaDim.labels{1})));
                else
                    try
                        if ismember(varName,["varfun","rowfun"])
                            switch nargin
                                case 3
                                    b=eval(varName+"(rowIndices,t)");
                                case 4
                                    b=eval(varName+"(rowIndices,t,colIndices)");
                                otherwise
                                    b=eval(varName+"(rowIndices,t,colIndices,varargin{:})");
                            end
                            return
                        end
                        switch nargin
                            case 2
                                b=eval(varName+"(t)");
                            case 3
                                b=eval(varName+"(t,rowIndices)");
                            case 4
                                b=eval(varName+"(t,rowIndices,colIndices)");
                            otherwise
                                b=eval(varName+"(t,rowIndices,colIndices,varargin{:})");
                        end
                    catch
                        tryThrowIllegalDotMethodError(t,varName,'MethodsWithNoCorrection',t.methodsWithNonTabularFirstArgument,'MessageCatalog','MATLAB:table');
                        error(message('MATLAB:table:UnrecognizedVarName',varName));
                    end
                    return
                end
            end
        end
    end
else
    error(message('MATLAB:table:IllegalVarSubscript'));
end

if varIndex > 0
    b = t.data{varIndex};
elseif varIndex == 0
    b = t.rowDim.labels;
else % varIndex == -1, all variables
    assert(false);
end

if isnumeric(rowIndices) || islogical(rowIndices) || isColon(rowIndices)
    % Can leave these alone to save overhead of calling subs2inds
else
    % Dot-parens or dot-braces subscripting might use row labels inherited from the
    % table, translate those to indices.
    if ~iscolumn(b) && (nargin < 4)
        error(message('MATLAB:table:InvalidLinearIndexing'));
    end
    numericRowIndices = t.rowDim.subs2inds(rowIndices);
%     subs2inds returns the indices as a col vector, but subscripting on a table
%     variable (as opposed to on a table) should follow the usual reshaping rules.
%     Nothing to do for one (char) name, including ':', but preserve a cellstr
%     subscript's original shape.
    if iscell(rowIndices) || isstring(rowIndices), numericRowIndices = reshape(numericRowIndices,size(rowIndices)); end
    rowIndices = numericRowIndices;
end

if nargin == 3
    b = b(rowIndices);
elseif nargin == 4
    b = b(rowIndices,colIndices);
else
    b = b(rowIndices,colIndices,varargin{:});
end
