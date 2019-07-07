$hyperv_host_list = get-vm -computername $env:computername

$vm_details = foreach($vm in $hyperv_host_list){

        $vmname = $vm.ComputerName
        $disk = $vm.HardDrives
        $disk_n = $disk.count
        [string]$memory = $vm.MemoryStartup /1gb
        $memory = $memory + "GB"
        $cpu = $vm.ProcessorCount
        $state = $vm.State
        $vm_ip = @((Resolve-DnsName -Name $vmname).ipaddress)
        [string]$vm_ip = $vm_ip -join " "


        $vhdsize = 0

        
        $disk | foreach{
                            $vhd = get-vhd -Path $_.path
                            $size = $vhd.Size
                            $vhdsize += $vhdsize + $size
                        }

        $vhdsize = [string]$vhdsize
        $vhdsize = $vhdsize /1gb
        [string]$vhdsize = [string]$vhdsize + "GB"


        # Host disk
        $disk = (get-wmiobject -Class "Win32_LogicalDisk").DeviceID

        $disk_size = @(
                        $disk | foreach{
                        $counter =  "\LogicalDisk($_)\Free Megabytes"
                        $host_disk_free_space = (get-counter -Counter $counter | select-object -ExpandProperty CounterSamples).cookedvalue
                        
                        $host_disk_free_space = [math]::Round($host_disk_free_space /1024)
                        $host_disk_free_space = [string]$host_disk_free_space + "GB"
                        $message = "$_ = $host_disk_free_space libre"
                        $message

                        }
                        )
        
       [string]$disk_size = $disk_size -join " "
        # vmhost  
        $vmhost = Get-VMHost -ComputerName $env:computername

        # host ip
        $host_ip = @((Resolve-DnsName -Name $env:computername).ipaddress)
        [string]$host_ip = $host_ip -join " "

        # host memory
        [string]$vmhost_memory = [math]::Round($vmhost.memorycapacity /1GB)
        $vmhost_memory = [string]$vmhost_memory + "GB"

        # Host CPU Count
        $vmhost_processor = $vmhost.LogicalProcessorCount

        # host Free memory
        $host_free_memory = (get-counter -Counter "\Memory\Available Bytes" | select-object -ExpandProperty CounterSamples).cookedvalue
        $host_free_memory = $host_free_memory /1gb
        $host_free_memory = [math]::Round([string]$host_free_memory)
        $host_free_memory = [string]$host_free_memory + "GB"

        # host CPU HOTE
        $host_cpu = (get-counter -Counter "\processor(_total)\% processor time" | select-object -ExpandProperty CounterSamples).cookedvalue
        $host_cpu = [math]::Round($host_cpu,2)
        $host_cpu = [string]$host_cpu + "%"
        
        [pscustomobject]@{

                    "VM Name" = $vmname
                    "VM State" = $state
                    "VM Number of vCPU" = $cpu
                    "VM Memory" = $memory
                    "VM Number of HardDrive" = $disk_n
                    "VM Total HardDrive Size" = $vhdsize
                    "VM IP address" = $vm_ip
                    "Hyper-V Host" = $env:computername
                    "Hyper-V Host IP" = $host_ip
                    "Hyper-V Host Number of Processor" = $vmhost_processor
                    "Hyper-V Host Free Memory" = $host_free_memory
                    "Hyper-V Host Maximum Memory" = $vmhost_memory
                    "Hyper-V Host processor" = $host_cpu
                    "Hyper-V Host Disk Free space" = $disk_size

                   }

        }

$txt = $env:computername + ".txt"

$savepath = "c:\windows\temp\$txt"

$vm_details | export-csv -path $savepath -NoTypeInformation -Encoding UTF8

$txt = $env:computername + ".txt"

$share = "\\10.0.0.1\share"
$remotec = "\\$env:computername\C$\windows\temp\$txt"

Copy-Item -Path $savepath -Destination $share -Force
