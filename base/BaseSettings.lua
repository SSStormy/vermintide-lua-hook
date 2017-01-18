ModLoaderSettings = ModLoaderSettings {}

ModLoaderSettings.default = 
{
    -- Redirects the print function to also call console.out
    redirect_print = false,
    -- Whether to create a console window or not
    create_console = false
}

ModLoaderSettings.debug = 
{
    redirect_print = true,
    create_console = true
}

