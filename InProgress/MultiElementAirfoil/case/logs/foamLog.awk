# header
BEGIN {
    Iteration=0
    resetCounters()
}

# reset counters used for variable postfix
function resetCounters() {
    contCumulativeCnt=0
    contGlobalCnt=0
    contLocalCnt=0
    CourantMaxCnt=0
    CourantMeanCnt=0
    executionTimeCnt=0
    nuTildaCnt=0
    nuTildaFinalResCnt=0
    nuTildaItersCnt=0
    pCnt=0
    pFinalResCnt=0
    pItersCnt=0
    SeparatorCnt=0
    TimeCnt=0
    UxCnt=0
    UxFinalResCnt=0
    UxItersCnt=0
    UyCnt=0
    UyFinalResCnt=0
    UyItersCnt=0
    # Reset counters for general Solving for extraction
    for (varName in subIter)
    {
        subIter[varName]=0
    }
}

# Extract value after columnSel
function extract(inLine,columnSel,outVar,a,b)
{
    a=index(inLine, columnSel)
    b=length(columnSel)
    split(substr(inLine, a+b),outVar)
    gsub("[,:]","",outVar[1])
}

# Iteration separator (increments 'Iteration')
/^[ \t]*Time = / {
    Iteration++
    resetCounters()
}

# Time extraction (sets 'Time')
/^[ \t]*Time = / {
    extract($0, "Time = ", val)
    Time=val[1]
}

# Skip whole line with singularity variable
/solution singularity/ {
    next;
}

    # Extraction of any solved for variable
    /Solving for/ {
        extract($0, "Solving for ", varNameVal)

        varName=varNameVal[1]
        file=varName "_" subIter[varName]++
        file="./logs/" file
        extract($0, "Initial residual = ", val)
        print Time "\t" val[1] > file

        varName=varNameVal[1] "FinalRes"
        file=varName "_" subIter[varName]++
        file="./logs/" file
        extract($0, "Final residual = ", val)
        print Time "\t" val[1] > file

        varName=varNameVal[1] "Iters"
        file=varName "_" subIter[varName]++
        file="./logs/" file
        extract($0, "No Iterations ", val)
        print Time "\t" val[1] > file
    }

# Extraction of contCumulative
/time step continuity errors :/ {
    extract($0, "cumulative = ", val)
    file="./logs/contCumulative_" contCumulativeCnt
    print Time "	" val[1] > file
    contCumulativeCnt++
}

# Extraction of contGlobal
/time step continuity errors :/ {
    extract($0, " global = ", val)
    file="./logs/contGlobal_" contGlobalCnt
    print Time "	" val[1] > file
    contGlobalCnt++
}

# Extraction of contLocal
/time step continuity errors :/ {
    extract($0, "sum local = ", val)
    file="./logs/contLocal_" contLocalCnt
    print Time "	" val[1] > file
    contLocalCnt++
}

# Extraction of CourantMax
/Courant Number / {
    extract($0, "max: ", val)
    file="./logs/CourantMax_" CourantMaxCnt
    print Time "	" val[1] > file
    CourantMaxCnt++
}

# Extraction of CourantMean
/Courant Number / {
    extract($0, "mean: ", val)
    file="./logs/CourantMean_" CourantMeanCnt
    print Time "	" val[1] > file
    CourantMeanCnt++
}

# Extraction of executionTime
/ExecutionTime = / {
    extract($0, "ExecutionTime = ", val)
    file="./logs/executionTime_" executionTimeCnt
    print Time "	" val[1] > file
    executionTimeCnt++
}

# Extraction of Separator
/^[ 	]*Time = / {
    extract($0, "Time = ", val)
    file="./logs/Separator_" SeparatorCnt
    print Time "	" val[1] > file
    SeparatorCnt++
}

# Extraction of Time
/^[ 	]*Time = / {
    extract($0, "Time = ", val)
    file="./logs/Time_" TimeCnt
    print Time "	" val[1] > file
    TimeCnt++
}

