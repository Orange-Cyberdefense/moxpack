    <?xml version="1.0" encoding="utf-8"?>
    <unattend xmlns="urn:schemas-microsoft-com:unattend">
        <servicing/>
        <settings pass="windowsPE">
            <component name="Microsoft-Windows-PnpCustomizationsWinPE"
                publicKeyToken="31bf3856ad364e35" language="neutral"
                versionScope="nonSxS" processorArchitecture="amd64"
                xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">

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
            <component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                <DiskConfiguration>
                    <Disk wcm:action="add">
                        <CreatePartitions>
                            <CreatePartition wcm:action="add">
                                <Order>1</Order>
                                <Type>Primary</Type>
                                <Extend>true</Extend>
                            </CreatePartition>
                        </CreatePartitions>
                        <ModifyPartitions>
                            <ModifyPartition wcm:action="add">
                                <Extend>false</Extend>
                                <Format>NTFS</Format>
                                <Letter>C</Letter>
                                <Order>1</Order>
                                <PartitionID>1</PartitionID>
                                <Label>Windows 10</Label>
                            </ModifyPartition>
                        </ModifyPartitions>
                        <DiskID>0</DiskID>
                        <WillWipeDisk>true</WillWipeDisk>
                    </Disk>
                    <WillShowUI>OnError</WillShowUI>
                </DiskConfiguration>
                <ImageInstall>
                    <OSImage>
                        <InstallTo>
                            <DiskID>0</DiskID>
                            <PartitionID>1</PartitionID>
                        </InstallTo>
                        <WillShowUI>OnError</WillShowUI>
                        <InstallToAvailablePartition>false</InstallToAvailablePartition>
                        <InstallFrom>
                            <MetaData wcm:action="add">
                                <Key>/IMAGE/NAME</Key>
                                <Value>${image_name}</Value>
                            </MetaData>
                        </InstallFrom>
                    </OSImage>
                </ImageInstall>
            <UserData>
                <!-- Product Key from https://www.microsoft.com/de-de/evalcenter/evaluate-windows-server-technical-preview?i=1 -->
                <ProductKey>
                    <!-- Do not uncomment the Key element if you are using trial ISOs -->
                    <!-- You must uncomment the Key element (and optionally insert your own key) if you are using retail or volume license ISOs -->
                    %{ if product_key != "" }
                    <Key>${product_key}</Key>
                    %{ endif }
                    <WillShowUI>OnError</WillShowUI>
                </ProductKey>
                <AcceptEula>true</AcceptEula>
                <FullName>Vagrant</FullName>
                <Organization>Vagrant</Organization>
            </UserData>
            </component>
            <component name="Microsoft-Windows-International-Core-WinPE" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                <SetupUILanguage>
                    <UILanguage>en-US</UILanguage>
                </SetupUILanguage>
                <InputLocale>en-US</InputLocale>
                <SystemLocale>en-US</SystemLocale>
                <UILanguage>en-US</UILanguage>
                <UILanguageFallback>en-US</UILanguageFallback>
                <UserLocale>en-US</UserLocale>
            </component>
        </settings>
        <!-- pass before the first boot -->
        <settings pass="specialize">
            <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                <OEMInformation>
                    <HelpCustomized>false</HelpCustomized>
                </OEMInformation>
                <ComputerName>${computer_name}</ComputerName>
                <TimeZone>${time_zone}</TimeZone>
                <RegisteredOwner/>
            </component>
            <component name="Microsoft-Windows-Security-SPP-UX" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                <SkipAutoActivation>true</SkipAutoActivation>
            </component>
        </settings>
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
                <ShowWindowsLive>false</ShowWindowsLive>
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
    <cpi:offlineImage cpi:source="wim:c:/wim/install.wim#${image_name}" xmlns:cpi="urn:schemas-microsoft-com:cpi" />
    </unattend>