<# 
.SYNOPSIS 
    Maps Drive Letters to SCSI TargetID
         
.DESCRIPTION 
    Helps to match VMWare VMDK scsi address to Windows scsi target IDs. This will list all "hard drives" (drivetype = 3) and the scsi bus, port, and targetid. You can match the TargetID to VMWare's (Bus:Disk) values in the VM's settings. It's not perfect - as the Bus numbers won't match, and there could be dupes of the TargetID/Disk.
    
    You need to match the TargetID to the Disk. For example:

        In VMWare, there are three disks, all the same size.
            HD1 = SCSI (0,0) and is 80gb
            HD2 = SCSI (0,9) and is 80gb
            HD3 = SCSI (0,8) and is 80gb

        Run Get-DiskToSCSI | ft Letter, TargetID, GB, FreeGB -AutoSize
            Letter TargetId         GB     FreeGB
            ------ --------         --     ------
            C:            0   79.99744   36.31427
            T:            8   79.99744   53.43123
            X:            9   79.99744    3.48348

        Match the TargetID to the 2nd number in parentheses and away you go.

 
.EXAMPLE 
    PS C:\> Get-DiskToSCSI | ft Letter, TargetID, GB, FreeGB -AutoSize

#>

# Get the  WMI objects
$Win32_LogicalDisk = Get-WmiObject -Class Win32_LogicalDisk -Filter "drivetype=3"
$Win32_LogicalDiskToPartition = Get-WmiObject -Class Win32_LogicalDiskToPartition
$Win32_DiskDriveToDiskPartition = Get-WmiObject -Class Win32_DiskDriveToDiskPartition
$Win32_DiskDrive = Get-WmiObject -Class Win32_DiskDrive

# Search the SCSI Lun Unit for the disk
$Win32_LogicalDisk | ForEach-Object {
    if ($_) { 
        $LogicalDisk = $_
        $LogicalDiskToPartition = $Win32_LogicalDiskToPartition | Where-Object {$_.Dependent -eq $LogicalDisk.Path}
        if ($LogicalDiskToPartition) {
            $DiskDriveToDiskPartition = $Win32_DiskDriveToDiskPartition | Where-Object {$_.Dependent -eq $LogicalDiskToPartition.Antecedent}
            if ($DiskDriveToDiskPartition) {
                $DiskDrive = $Win32_DiskDrive | Where-Object {$_.__Path -eq $DiskDriveToDiskPartition.Antecedent}
                if ($DiskDrive) {
                    if ($DiskDrive.Size) { $GB = [math]::Round($DiskDrive.Size / 1GB, 5) }
                    if ($LogicalDisk.FreeSpace) { $Free = [math]::round($LogicalDisk.FreeSpace / 1GB, 5) }
                    else { $GB = 0 }
                    $InfoHash = @{
                        Letter = $LogicalDisk.DeviceID
                        Bus = $DiskDrive.SCSIBus
                        Port = $DiskDrive.SCSIPort
                        TargetId = $DiskDrive.SCSITargetId
                        LogicalUnit = $DiskDrive.SCSILogicalUnit
                        SizeGB = $GB
                        FreeGB = $Free
                        Disk = $DiskDrive.DeviceID
                    }
                }
            }
        }
    }
    $InfoStack = New-Object -TypeName PSObject -Property $InfoHash

    #Add a (hopefully) unique object type name
    $InfoStack.PSTypeNames.Insert(0,"Disk.Information")
    
    #Sets the "default properties" when outputting the variable... but really for setting the order
    $defaultProperties = @('Letter', 'SizeGB', 'FreeGB', 'TargetId')
    $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet(‘DefaultDisplayPropertySet’,[string[]]$defaultProperties)
    $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
    $InfoStack | Add-Member MemberSet PSStandardMembers $PSStandardMembers
    
    $InfoStack
}