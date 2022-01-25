Function slaCalculate(receivedTimeString As String, endTime As Date, Project As String, Task As String, subTask As String)
Dim slaTimeLimit As Long
Dim Result As Date
Dim Res As String
Dim addType As String
Dim supportDays As Integer
Dim ShiftStartTimeString As String
Dim ShiftEndTimeString As String
Dim receivedTime, Workinghrs, ShiftStartTime, ShiftEndTime, FridayDate As Date
Dim tempHrCal, tempHrCal2, WeekendHrs As Long


receivedTime = CDate(receivedTimeString)


For I = 1 To 400
    
    If ThisWorkbook.Sheets("Setting").Range("B" & I).Value = Project And ThisWorkbook.Sheets("Setting").Range("C" & I).Value = subTask And ThisWorkbook.Sheets("Setting").Range("D" & I).Value = Task Then
        addType = Sheets("Setting").Range("F" & I).Value
        supportDays = Sheets("Setting").Range("G" & I).Value
        slaTimeLimit = Sheets("Setting").Range("E" & I).Value
        ShiftStartTimeString = Sheets("Setting").Range("H" & I).Value
        ShiftEndTimeString = Sheets("Setting").Range("I" & I).Value
        Exit For
    End If
Next

ShiftStartTime = CDate(ShiftStartTimeString)
ShiftEndTime = CDate(ShiftEndTimeString)

'convert sla to minutes for easy calculation
If addType = "hours" Then slaTimeLimit = slaTimeLimit * 60
    If addType = "days" Then slaTimeLimit = slaTimeLimit * (24 * 60)


'tempHrCal = WorksheetFunction.Text(WorksheetFunction.Text(ShiftEndTime, "HH:mm") - WorksheetFunction.Text(receivedTimeString, "HH:mm"), 0)
tempHrCal = DateDiff("h", receivedTime, CDate(DateSerial(Year:=Year(receivedTime), Month:=Month(receivedTime), Day:=Day(receivedTime)) & " " & TimeSerial(Hour:=Hour(ShiftEndTime), Minute:=Minute(ShiftEndTime), Second:=Second(ShiftEndTime))))

tempHrCal = (slaTimeLimit / 60) - tempHrCal
'tempHrCal2 = WorksheetFunction.RoundUp(tempHrCal / (WorksheetFunction.Text(WorksheetFunction.Text(ShiftEndTime, "HH:mm") - WorksheetFunction.Text(ShiftStartTime, "HH:mm"), 0)))
tempHrCal2 = WorksheetFunction.RoundUp(tempHrCal / DateDiff("h", ShiftStartTime, ShiftEndTime), 0)
tempHrCal2 = tempHrCal2 * (24 - (DateDiff("h", ShiftStartTime, ShiftEndTime)))

tempHrCal2 = (tempHrCal2 * 60) + slaTimeLimit


If supportDays = 7 Then
    WeekendHrs = 0
ElseIf supportDays = 5 Then
    FridayDate = DateAdd("d", 8 - Weekday(receivedTime, vbFriday), receivedTime)
    FridayDate = CDate(DateSerial(Year:=Year(FridayDate), Month:=Month(FridayDate), Day:=Day(FridayDate)) & " " & TimeSerial(Hour:=Hour(ShiftEndTime), Minute:=Minute(ShiftEndTime), Second:=Second(ShiftEndTime)))
    
    WeekendHrs = (TimeSerial(24, 0, 0)) * (DateDiff("h", ShiftStartTime, ShiftEndTime)) - WorksheetFunction.NetworkDays(receivedTime, FridayDate)

    If (WorksheetFunction.NetworkDays(endTime, FridayDate) = 1) Then
        If UBound(Split(CStr(CDbl(receivedTime)), ".")) <= 0 Then
        WeekendHrs = WeekendHrs + WorksheetFunction.Median(0, ShiftEndTime, ShiftStartTime)
        Else
        WeekendHrs = WeekendHrs + WorksheetFunction.Median(WorksheetFunction.MOD(FridayDate, 1), ShiftStartTime, ShiftEndTime)
        End If
    Else
        WeekendHrs = WeekendHrs + (DateDiff("h", ShiftStartTime, ShiftEndTime))
    End If
    If UBound(Split(CStr(CDbl(receivedTime)), ".")) <= 0 Then
        WeekendHrs = WeekendHrs - WorksheetFunction.Median(WorksheetFunction.NetworkDays(receivedTime, receivedTime) * 0, ShiftEndTime, ShiftStartTime)
        WeekendHrs = WorksheetFunction.RoundUp(((slaTimeLimit / 60) - WeekendHrs) / (DateDiff("h", ShiftStartTime, ShiftEndTime) * 5), 0)
        WeekendHrs = WeekendHrs * 48
    Else
        WeekendHrs = WeekendHrs - WorksheetFunction.Median(WorksheetFunction.NetworkDays(receivedTime, receivedTime) * Split(CStr(CDbl(receivedTime)), ".")(1), ShiftEndTime, ShiftStartTime)
        WeekendHrs = WorksheetFunction.RoundUp(((slaTimeLimit / 60) - WeekendHrs) / (DateDiff("h", ShiftStartTime, ShiftEndTime) * 5), 0)
        WeekendHrs = WeekendHrs * 48
    End If
    
    
End If

slaCalculate = receivedTime + TimeSerial(0, tempHrCal2, 0) + TimeSerial(WeekendHrs, 0, 0)



'ppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp

'
'Result = (WorksheetFunction.NetworkDays(receivedTime, endTime) - 1) * (ShiftEndTime - ShiftStartTime)
'
'If (WorksheetFunction.NetworkDays(endTime, endTime) = 1) Then
'    Result = Result + WorksheetFunction.Median(WorksheetFunction.MOD(endTime, 1), ShiftEndTime, ShiftStartTime)
'Else
'    Result = Result + ShiftEndTime
'End If
'
'Result = Result - WorksheetFunction.Median(WorksheetFunction.NetworkDays(receivedTime, receivedTime) * WorksheetFunction.MOD(receivedTime, 1), ShiftEndTime, ShiftStartTime)



End Function

Sub test()
MsgBox Application.WorksheetFunction.RoundUp(0.05, 0)
End Sub


