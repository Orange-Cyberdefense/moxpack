<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <!-- pass during windows install screen -->
    <settings pass="windowsPE">
        <component name="Microsoft-Windows-PnpCustomizationsWinPE" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" processorArchitecture="amd64" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">

            <!--
                 This makes the VirtIO drivers available to Windows, assuming that
                 the VirtIO driver disk at https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
                 (see https://docs.fedoraproject.org/en-US/quick-docs/creating-windows-virtual-machines-using-virtio-drivers/index.html#virtio-win-direct-downloads)
                 is available as drive F:
            -->
            <DriverPaths>
                <PathAndCredentials wcm:action="add" wcm:keyValue="2">
                    <Path>F:\viostor\${version}\amd64</Path>
                </PathAndCredentials>

                <PathAndCredentials wcm:action="add" wcm:keyValue="3">
                    <Path>F:\NetKVM\${version}\amd64</Path>
                </PathAndCredentials>

                <PathAndCredentials wcm:action="add" wcm:keyValue="4">
                    <Path>F:\Balloon\${version}\amd64</Path>
                </PathAndCredentials>

                <PathAndCredentials wcm:action="add" wcm:keyValue="5">
                    <Path>F:\pvpanic\${version}\amd64</Path>
                </PathAndCredentials>

                <PathAndCredentials wcm:action="add" wcm:keyValue="6">
                    <Path>F:\qemupciserial\${version}\amd64</Path>
                </PathAndCredentials>

                <PathAndCredentials wcm:action="add" wcm:keyValue="7">
                    <Path>F:\qxldod\${version}\amd64</Path>
                </PathAndCredentials>

                <PathAndCredentials wcm:action="add" wcm:keyValue="8">
                    <Path>F:\vioinput\${version}\amd64</Path>
                </PathAndCredentials>

                <PathAndCredentials wcm:action="add" wcm:keyValue="9">
                    <Path>F:\viorng\${version}\amd64</Path>
                </PathAndCredentials>

                <PathAndCredentials wcm:action="add" wcm:keyValue="10">
                    <Path>F:\vioscsi\${version}\amd64</Path>
                </PathAndCredentials>

                <PathAndCredentials wcm:action="add" wcm:keyValue="11">
                    <Path>F:\vioserial\${version}\amd64</Path>
                </PathAndCredentials>
            </DriverPaths>
        </component>
        <component name="Microsoft-Windows-International-Core-WinPE" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <SetupUILanguage>
                <UILanguage>en-US</UILanguage>
            </SetupUILanguage>
            <InputLocale>en-US</InputLocale>
            <SystemLocale>en-US</SystemLocale>
            <UILanguage>en-US</UILanguage>
            <UserLocale>en-US</UserLocale>
        </component>
        <component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <!-- This bypasses the TPM, Secure boot, and RAM checks during install -->
            <RunSynchronous>
                <RunSynchronousCommand wcm:action="add">
                    <Order>1</Order>
                    <Description>BypassTPMCheck</Description>
                    <Path>cmd /c reg add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassTPMCheck" /t REG_DWORD /d 1</Path>
                </RunSynchronousCommand>
                <RunSynchronousCommand wcm:action="add">
                    <Order>2</Order>
                    <Description>BypassSecureBootCheck</Description>
                    <Path>cmd /c reg add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassSecureBootCheck" /t REG_DWORD /d 1</Path>
                </RunSynchronousCommand>
                <RunSynchronousCommand wcm:action="add">
                    <Order>3</Order>
                    <Description>BypassRAMCheck</Description>
                    <Path>cmd /c reg add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassRAMCheck" /t REG_DWORD /d 1</Path>
                </RunSynchronousCommand>
             </RunSynchronous>
            <DiskConfiguration>
                <Disk wcm:action="add">
                    <DiskID>0</DiskID>
                    <WillWipeDisk>true</WillWipeDisk>
                    <CreatePartitions>
                        <!-- Windows RE Tools partition -->
                        <CreatePartition wcm:action="add">
                            <Order>1</Order>
                            <Type>Primary</Type>
                            <Size>300</Size>
                        </CreatePartition>
                        <!-- System partition (ESP) -->
                        <CreatePartition wcm:action="add">
                            <Order>2</Order>
                            <Type>EFI</Type>
                            <Size>100</Size>
                        </CreatePartition>
                        <!-- Microsoft reserved partition (MSR) -->
                        <CreatePartition wcm:action="add">
                            <Order>3</Order>
                            <Type>MSR</Type>
                            <Size>128</Size>
                        </CreatePartition>
                        <!-- Windows partition -->
                        <CreatePartition wcm:action="add">
                            <Order>4</Order>
                            <Type>Primary</Type>
                            <Extend>true</Extend>
                        </CreatePartition>
                    </CreatePartitions>
                    <ModifyPartitions>
                        <!-- Windows RE Tools partition -->
                        <ModifyPartition wcm:action="add">
                            <Order>1</Order>
                            <PartitionID>1</PartitionID>
                            <Label>WINRE</Label>
                            <Format>NTFS</Format>
                            <TypeID>DE94BBA4-06D1-4D40-A16A-BFD50179D6AC</TypeID>
                        </ModifyPartition>
                        <!-- System partition (ESP) -->
                        <ModifyPartition wcm:action="add">
                            <Order>2</Order>
                            <PartitionID>2</PartitionID>
                            <Label>System</Label>
                            <Format>FAT32</Format>
                        </ModifyPartition>
                        <!-- MSR partition does not need to be modified -->
                        <ModifyPartition wcm:action="add">
                            <Order>3</Order>
                            <PartitionID>3</PartitionID>
                        </ModifyPartition>
                        <!-- Windows partition -->
                        <ModifyPartition wcm:action="add">
                            <Order>4</Order>
                            <PartitionID>4</PartitionID>
                            <Label>OS</Label>
                            <Letter>C</Letter>
                            <Format>NTFS</Format>
                        </ModifyPartition>
                    </ModifyPartitions>
                </Disk>
            </DiskConfiguration>
            <UserData>
                <AcceptEula>true</AcceptEula>
                <FullName>User</FullName>
                <Organization>User Inc.</Organization>
                <ProductKey>
                    <WillShowUI>Never</WillShowUI>
                </ProductKey>
            </UserData>
            <ImageInstall>
                <OSImage>
                    <InstallTo>
                        <DiskID>0</DiskID>
                        <PartitionID>4</PartitionID>
                    </InstallTo>
                    <WillShowUI>OnError</WillShowUI>
                    <InstallToAvailablePartition>false</InstallToAvailablePartition>
                    <InstallFrom>
                        <MetaData wcm:action="add">
                            <!-- Name doesn't work on win11
                            <Key>/IMAGE/INDEX</Key> 
                            <Value>${image_name}</Value> -->
                            <Key>/IMAGE/NAME</Key>
                            <Value>${image_name}</Value>
                        </MetaData>
                    </InstallFrom>
                </OSImage>
            </ImageInstall>
        </component>
    </settings>
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <ComputerName>${computer_name}</ComputerName>
            <TimeZone>${time_zone}</TimeZone>
        </component>
        <component xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" name="Microsoft-Windows-Security-SPP-UX" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <SkipAutoActivation>true</SkipAutoActivation>
        </component>
        <component name="Microsoft-Windows-TerminalServices-LocalSessionManager" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <fDenyTSConnections>false</fDenyTSConnections>
        </component>
        <component name="Networking-MPSSVC-Svc" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <FirewallGroups>
                <FirewallGroup wcm:action="add" wcm:keyValue="RemoteDesktop">
                    <Active>true</Active>
                    <Group>Remote Desktop</Group>
                    <Profile>all</Profile>
                </FirewallGroup>
            </FirewallGroups>
        </component>
        <component name="Microsoft-Windows-TerminalServices-RDP-WinStationExtensions" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <UserAuthentication>0</UserAuthentication>
        </component>
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <InputLocale>en-US</InputLocale>
            <SystemLocale>en-US</SystemLocale>
            <UILanguage>en-US</UILanguage>
            <UserLocale>en-US</UserLocale>
        </component>
    </settings>
    <!-- pass after the boot : out of box experience -->
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <AutoLogon>
                <Password>
                    <Value>${password}</Value>
                    <PlainText>true</PlainText>
                </Password>
                <Enabled>true</Enabled>
                <Username>${username}</Username>
            </AutoLogon>
             <FirstLogonCommands>
                <SynchronousCommand wcm:action="add">
                    <CommandLine>reg add HKLM\System\CurrentControlSet\Control\Network\NewNetworkWindowOff</CommandLine>
                    <Description>Disable Network prompt</Description>
                    <Order>1</Order>
                </SynchronousCommand>
                <SynchronousCommand wcm:action="add">
                    <CommandLine>powershell -NoProfile -ExecutionPolicy Bypass E:\disable-winrm.ps1</CommandLine>
                    <Description>Disable WinRM to wait for the end before provisioning</Description>
                    <Order>2</Order>
                    <RequiresUserInput>true</RequiresUserInput>
                </SynchronousCommand>
                <SynchronousCommand wcm:action="add">
                    <Order>3</Order>
                    <CommandLine>powershell -NoProfile -ExecutionPolicy Bypass E:\win-setup.ps1</CommandLine>
                    <Description>Run the setup script</Description>
                </SynchronousCommand>
                <SynchronousCommand wcm:action="add">
                    <CommandLine>powershell -NoProfile -ExecutionPolicy Bypass E:\ConfigureRemotingForAnsible.ps1</CommandLine>
                    <Description>ConfigureRemotingForAnsible</Description>
                    <Order>99</Order>
                </SynchronousCommand>
            </FirstLogonCommands>
            <OOBE>
                <HideLocalAccountScreen>true</HideLocalAccountScreen>
                <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
                <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
                <NetworkLocation>Work</NetworkLocation>
                <!-- 1: Specifies that important and recommended updates are installed automatically.
                     2: Specifies that only important updates are installed.
                     3: Specifies that automatic protection is disabled. Updates are available manually through Windows Update. -->
                <ProtectYourPC>3</ProtectYourPC>
                <HideEULAPage>true</HideEULAPage>
                <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
            </OOBE>
            <UserAccounts>
                <AdministratorPassword>
                    <Value>${admin_password}</Value>
                    <PlainText>true</PlainText>
                </AdministratorPassword>
                <LocalAccounts>
                    <LocalAccount wcm:action="add">
                        <Password>
                            <Value>${password}</Value>
                            <PlainText>true</PlainText>
                        </Password>
                        <Name>${username}</Name>
                        <DisplayName>${username}</DisplayName>
                        <Group>administrators</Group>
                        <Description>${username} User</Description>
                    </LocalAccount>
                </LocalAccounts>
            </UserAccounts>
            <TimeZone>${time_zone}</TimeZone>
        </component>
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <InputLocale>${keyboard}</InputLocale> <!-- US + FR -->
            <SystemLocale>en-US</SystemLocale>
            <UILanguage>en-US</UILanguage>
            <UserLocale>en-US</UserLocale>
        </component>
    </settings>
    <settings pass="offlineServicing">
        <component name="Microsoft-Windows-LUA-Settings" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <EnableLUA>false</EnableLUA>
        </component>
    </settings>
    <cpi:offlineImage xmlns:cpi="urn:schemas-microsoft-com:cpi" cpi:source="catalog:d:/sources/install_windows 10 ENTERPRISE.clg"/>
</unattend>