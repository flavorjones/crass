module Crass

  # Similar to a StringScanner, but with extra functionality needed to tokenize
  # CSS while preserving the original text.
  class Scanner
    # Current character, or `nil` if the scanner hasn't yet consumed a
    # character, or is at the end of the string.
    attr_reader :current

    # Current marker position. Use {#marked} to get the substring between
    # {#marker} and {#pos}.
    attr_accessor :marker

    # Position of the next character that will be consumed. This is a character
    # position, not a byte position, so it accounts for multi-byte characters.
    attr_accessor :pos

    # The string being scanned.
    attr_reader :string

    # Creates a Scanner instance for the given _input_ string or IO instance.
    def initialize(input)
      @string = input.is_a?(IO) ? input.read : input.to_s
      @chars  = @string.chars.to_a

      reset
    end

    # Consumes the next character and returns it, advancing the pointer, or
    # an empty string if the end of the string has been reached.
    def consume
      @current = @chars[@pos] || ''
      @pos += 1 if @current
      @current
    end

    # Consumes the rest of the string and returns it, advancing the pointer to
    # the end of the string. Returns an empty string is the end of the string
    # has already been reached.
    def consume_rest
      rest     = @string[@pos..@len] || ''
      @current = rest[-1] || ''
      @pos     = @len

      rest
    end

    # Returns `true` if the end of the string has been reached, `false`
    # otherwise.
    def eos?
      @pos == @len
    end

    # Sets the marker to the position of the next character that will be
    # consumed.
    def mark
      @marker = @pos
    end

    # Returns the substring between {#marker} and {#pos}, without altering the
    # pointer.
    def marked
      if result = @chars[@marker...@pos]
        result.join('')
      else
        ''
      end
    end

    # Returns up to _length_ characters starting at the current position, but
    # doesn't consume them. The number of characters returned may be less than
    # _length_ if the end of the string is reached.
    def peek(length = 1)
      if result = @chars[@pos, length]
        result.join('')
      else
        ''
      end
    end

    # Moves the pointer back one character without changing the value of
    # {#current}. The next call to {#consume} will re-consume the current
    # character.
    def reconsume
      @pos -= 1 if @pos > 0
    end

    # Resets the pointer to the beginning of the string.
    def reset
      @current = nil
      @len     = @string.length
      @marker  = 0
      @pos     = 0
    end

    # Tries to match _pattern_ at the current position. If it matches, the
    # matched substring will be returned and the pointer will be advanced.
    # Otherwise, `nil` will be returned.
    def scan(pattern)
      match = pattern.match(@string, @pos)
      return nil if match.nil? || match.begin(0) != @pos

      @pos     = match.end(0)
      @current = @chars[@pos - 1]

      match[0]
    end

    # Scans the string until the _pattern_ is matched. Returns the substring up
    # to and including the end of the match, and advances the pointer. If there
    # is no match, `nil` is returned and the pointer is not advanced.
    def scan_until(pattern)
      start = @pos
      match = pattern.match(@string, @pos)

      return nil if match.nil?

      @pos     = match.end(0)
      @current = @chars[@pos - 1]

      @string[start...@pos]
    end
  end

end
