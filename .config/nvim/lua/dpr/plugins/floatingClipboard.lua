return {
  "hamzahshahbazkhan/floatingClipboard.nvim",
  config = function()
    require("floatingClipboard").setup({ target_file = "~/.clipboard.txt" })
  end,
}
